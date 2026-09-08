/*
 * Copyright (C) 2007-2026 Crafter Software Corporation. All Rights Reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.craftercms.studio.impl.v2.service.dependency.internal;

import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.craftercms.commons.security.permissions.PermissionEvaluator;
import org.craftercms.studio.api.v1.constant.DmConstants;
import org.craftercms.studio.api.v1.exception.ServiceLayerException;
import org.craftercms.studio.api.v1.service.GeneralLockService;
import org.craftercms.studio.api.v1.service.configuration.ServicesConfig;
import org.craftercms.studio.api.v1.service.dependency.DependencyResolver;
import org.craftercms.studio.api.v1.service.dependency.DependencyResolver.ResolvedDependency;
import org.craftercms.studio.api.v2.annotation.LogExecutionTime;
import org.craftercms.studio.api.v2.annotation.RequireSiteExists;
import org.craftercms.studio.api.v2.annotation.SiteId;
import org.craftercms.studio.api.v2.dal.Dependency;
import org.craftercms.studio.api.v2.dal.DependencyDAO;
import org.craftercms.studio.api.v2.dal.RetryingDatabaseOperationFacade;
import org.craftercms.studio.api.v2.service.dependency.internal.DependencyServiceInternal;
import org.craftercms.studio.api.v2.service.item.internal.ItemServiceInternal;
import org.craftercms.studio.api.v2.service.security.SecurityService;
import org.craftercms.studio.api.v2.utils.StudioConfiguration;
import org.craftercms.studio.impl.v1.util.ContentUtils;
import org.craftercms.studio.model.rest.content.DependencyItem;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.transaction.annotation.Transactional;

import java.nio.file.Path;
import java.util.*;
import java.util.stream.Collectors;

import static java.lang.String.format;
import static org.apache.commons.collections4.CollectionUtils.isNotEmpty;
import static org.apache.commons.lang3.StringUtils.removeEnd;
import static org.craftercms.studio.api.v1.constant.DmConstants.SLASH_INDEX_FILE;
import static org.craftercms.studio.api.v1.constant.StudioConstants.FILE_SEPARATOR;
import static org.craftercms.studio.api.v1.constant.StudioConstants.INDEX_FILE;
import static org.craftercms.studio.api.v2.dal.DependencyDAO.SOURCE_PATH_COLUMN_NAME;
import static org.craftercms.studio.api.v2.dal.DependencyDAO.TARGET_PATH_COLUMN_NAME;
import static org.craftercms.studio.api.v2.dal.ItemState.MODIFIED_MASK;
import static org.craftercms.studio.api.v2.dal.ItemState.NEW_MASK;
import static org.craftercms.studio.api.v2.utils.StudioConfiguration.CONFIGURATION_DEPENDENCY_ITEM_SPECIFIC_PATTERNS;
import static org.craftercms.studio.impl.v2.utils.DependencyUtils.isValidDependencyPath;
import static org.craftercms.studio.permissions.StudioPermissionsConstants.PATH_RESOURCE_ID;
import static org.craftercms.studio.permissions.StudioPermissionsConstants.PERMISSION_PUBLISH;
import static org.craftercms.studio.permissions.StudioPermissionsConstants.SITE_ID_RESOURCE_ID;

public class DependencyServiceInternalImpl implements DependencyServiceInternal {

    private static final Logger logger = LoggerFactory.getLogger(DependencyServiceInternalImpl.class);
    private static final String UPSERT_DEPENDENCIES_LOCK = ":upsertDependencies";

    private StudioConfiguration studioConfiguration;
    private DependencyDAO dependencyDao;
    private ItemServiceInternal itemServiceInternal;
    private DependencyResolver dependencyResolver;
    private ServicesConfig servicesConfig;
    private GeneralLockService generalLockService;
    private RetryingDatabaseOperationFacade retryingDatabaseOperationFacade;
	private PermissionEvaluator permissionEvaluator;
	private SecurityService securityService;

    @Override
    @LogExecutionTime
    public Collection<String> getSoftDependencies(String site, List<String> paths) {
        logger.trace("Get all soft dependencies for site '{}' paths '{}'", site, paths);
        Set<String> pathsParams = new HashSet<>(paths);
		Set<String> result = new HashSet<>();
		List<Map<String, String>> deps = dependencyDao.getSoftDependenciesForList(site, pathsParams,
				getItemSpecificDependenciesPatterns(),
				MODIFIED_MASK, NEW_MASK);
		for (Map<String, String> d : deps) {
			String targetPath = d.get(TARGET_PATH_COLUMN_NAME);
			if (!pathsParams.contains(targetPath)) {
				Object resource = Map.of(SITE_ID_RESOURCE_ID, site, PATH_RESOURCE_ID, targetPath);
				boolean hasPermission = permissionEvaluator.isAllowed(securityService.getCurrentUser(), resource,
						PERMISSION_PUBLISH);
				if (hasPermission) {
					result.add(targetPath);
				}
			}
		}
        return result;
    }

    protected List<String> getItemSpecificDependenciesPatterns() {
        StringTokenizer st = new StringTokenizer(
                studioConfiguration.getProperty(CONFIGURATION_DEPENDENCY_ITEM_SPECIFIC_PATTERNS), ",");
        List<String> itemSpecificDependenciesPatterns = new ArrayList<>(st.countTokens());
        while (st.hasMoreTokens()) {
            itemSpecificDependenciesPatterns.add(st.nextToken().trim());
        }
        return itemSpecificDependenciesPatterns;
    }

    @Override
    @RequireSiteExists
    public List<String> getHardDependencies(@SiteId String site, List<String> paths) {
        Map<String, String> dependencies = calculateHardDependencies(site, paths);
        // Prevent returning the paths as dependencies of themselves
        return List.copyOf(CollectionUtils.subtract(dependencies.keySet(), paths));
    }

    /**
     * Get the list of mandatory parents for publishing the given paths.
     * A mandatory parent is any ancestor page that has
     * never been published (it is either new or moved)
     *
     * @param site  site name
     * @param paths list of paths to publish
     * @return list of mandatory parents
     */
    private List<String> getMandatoryParents(final String site, final List<String> paths) {
        Set<String> possibleParents = new HashSet<>();
        for (String path : paths) {
            StringTokenizer stPath = new StringTokenizer(removeEnd(path, SLASH_INDEX_FILE), FILE_SEPARATOR);
            StringBuilder candidate = new StringBuilder(FILE_SEPARATOR);
            stPath.asIterator().forEachRemaining(token -> {
                candidate.append(token).append(FILE_SEPARATOR);
                possibleParents.add(candidate + INDEX_FILE);
            });
        }
        List<String> allPaths = new ArrayList<>(paths);
        allPaths.addAll(possibleParents);

        return itemServiceInternal.getMandatoryParentsForPublishing(site, allPaths);
    }

    private Map<String, String> calculateHardDependencies(String site, List<String> paths) {
        Set<String> toRet = new HashSet<>();

        logger.trace("Get all hard dependencies for site '{}' paths '{}'", site, paths);
        Set<String> pathsParams = new HashSet<>(paths);
        List<String> mandatoryParents = getMandatoryParents(site, paths);
        Map<String, String> ancestors = new HashMap<>();
        if (isNotEmpty(mandatoryParents)) {
            pathsParams.addAll(mandatoryParents);
            Set<String> existingRenamedChildrenOfMandatoryParents =
                    getExistingRenamedChildrenOfMandatoryParents(site, mandatoryParents);
            for (String p3 : existingRenamedChildrenOfMandatoryParents) {
                ancestors.put(p3, p3);
            }
            pathsParams.addAll(existingRenamedChildrenOfMandatoryParents);
        }
        boolean exitCondition = false;

        for (String p : mandatoryParents) {
            String prefix = p.replace(FILE_SEPARATOR + INDEX_FILE, "");
            for (String p2 : paths) {
                if (p2.startsWith(prefix)) {
                    ancestors.put(p, p2);
                    break;
                }
            }

        }
        do {
            List<Map<String, String>> deps = calculateHardDependenciesForListFromDB(site, pathsParams);
            List<String> targetPaths = new ArrayList<>();
            for (Map<String, String> d : deps) {
                String srcPath = d.get(SOURCE_PATH_COLUMN_NAME);
                String targetPath = d.get(TARGET_PATH_COLUMN_NAME);
                if (!ancestors.containsKey(targetPath) &&
                        !StringUtils.equals(targetPath, ancestors.get(srcPath))) {
                    ancestors.put(targetPath, ancestors.get(srcPath));
                }
                targetPaths.add(targetPath);
            }
            exitCondition = !toRet.addAll(targetPaths);
            pathsParams.clear();
            pathsParams.addAll(targetPaths);
        } while (!exitCondition);

        return ancestors;
    }

    private Set<String> getExistingRenamedChildrenOfMandatoryParents(String site, List<String> paths) {
        Set<String> toRet = new HashSet<>(itemServiceInternal.getExistingRenamedChildrenOfMandatoryParentsForPublishing(site, paths));
        return toRet;
    }

    private List<Map<String, String>> calculateHardDependenciesForListFromDB(String site, Set<String> paths) {
        return dependencyDao.getHardDependenciesForList(site, paths, getItemSpecificDependenciesPatterns(),
                MODIFIED_MASK, NEW_MASK);
    }

    @Override
    public List<String> getDependentPaths(String siteId, List<String> paths) {
        if (CollectionUtils.isEmpty(paths)) {
            return new ArrayList<>();
        }
        List<String> result = dependencyDao.getDependentItems(siteId, paths);
        return result.stream().distinct().collect(Collectors.toList());
    }

    @Override
    public List<DependencyItem> getDependentItems(String siteId, String path) {
        List<String> dependentPaths = dependencyDao.getDependentItems(siteId, Collections.singletonList(path))
                .stream().distinct().collect(Collectors.toList());

        return dependentPaths.stream()
                .map(dep -> DependencyItem.getInstance(itemServiceInternal.getItem(siteId, dep)))
                .collect(Collectors.toList());
    }

    @Override
    public List<String> getItemSpecificDependencies(String siteId, String path) {
        List<String> paths = new ArrayList<>(1);
        paths.add(path);
        return getItemSpecificDependencies(siteId, paths);
    }

    @Override
    public List<String> getItemSpecificDependencies(String siteId, List<String> paths) {
        if (isNotEmpty(paths)) {
            return dependencyDao.getItemSpecificDependencies(siteId, paths, getItemSpecificDependenciesPatterns());
        } else {
            return new ArrayList<>();
        }
    }

    @Override
    @LogExecutionTime
    public Map<String, Set<ResolvedDependency>> resolveDependencies(String siteId, String path) {
        Map<String, Set<ResolvedDependency>> dependencies = null;
        if (isValidDependencySource(siteId, path)) {
            dependencies = dependencyResolver.resolve(siteId, path);
        }
        return dependencies;
    }

    @Override
    @Transactional
    public void upsertDependencies(String site, String path) throws ServiceLayerException {
        Map<String, Set<ResolvedDependency>> resolveDependencies = dependencyResolver.resolve(site, path);
        List<Dependency> dependencies = new LinkedList<>();
        for (Map.Entry<String, Set<ResolvedDependency>> entry : resolveDependencies.entrySet()) {
            dependencies.addAll(
                    entry.getValue().stream()
                            .filter(dep -> isValidDependencyPath(dep.path()))
                            .map(dep -> {
                                Dependency dependency = new Dependency();
                                dependency.setSite(site);
                                // Remove multiple slashes
                                dependency.setSourcePath(Path.of(path).toString());
                                dependency.setTargetPath(Path.of(dep.path()).toString());
                                dependency.setType(entry.getKey());
                                dependency.setValid(dep.valid());
                                return dependency;
                            }).toList());
        }
        String lock = site + UPSERT_DEPENDENCIES_LOCK;
        generalLockService.lock(lock);
        try {
            logger.debug("Upserting dependencies for site '{}' path '{}'", site, path);
            retryingDatabaseOperationFacade.retry(() -> dependencyDao.deleteItemDependencies(site, path));
            if (isNotEmpty(dependencies)) {
                retryingDatabaseOperationFacade.retry(() -> dependencyDao.insertItemDependencies(dependencies));
            }
        } catch (Exception e) {
            logger.error("Failed to upsert dependencies for site '{}' path '{}'", site, path, e);
            throw new ServiceLayerException(format("Failed to upsert dependencies for site '%s' path '%s'",
                    site, path), e);
        } finally {
            generalLockService.unlock(lock);
        }
    }

    @Override
    public void deleteItemDependencies(String site, String sourcePath) throws ServiceLayerException {
        try {
            retryingDatabaseOperationFacade.retry(() -> dependencyDao.deleteItemDependencies(site, sourcePath));
        } catch (Exception e) {
            logger.error("Failed to delete dependencies for site '{}' path '{}'", site, sourcePath, e);
            throw new ServiceLayerException(format("Failed to delete dependencies for site '%s' path '%s'",
                    site, sourcePath), e);
        }
    }

    @Override
    public void invalidateDependencies(String siteId, String targetPath) throws ServiceLayerException {
        try {
            retryingDatabaseOperationFacade.retry(() -> dependencyDao.invalidateDependencies(siteId, targetPath));
        } catch (Exception e) {
            logger.error("Failed to invalidate dependencies for site '{}' path '{}'", siteId, targetPath, e);
            throw new ServiceLayerException(format("Failed to invalidate dependencies for site '%s' path '%s'",
                    siteId, targetPath), e);
        }
    }

    @Override
    public void validateDependencies(String siteId, String targetPath) throws ServiceLayerException {
        try {
            retryingDatabaseOperationFacade.retry(() -> dependencyDao.validateDependencies(siteId, targetPath));
        } catch (Exception e) {
            logger.error("Failed to validate dependencies for site '{}' path '{}'", siteId, targetPath, e);
            throw new ServiceLayerException(format("Failed to validate dependencies for site '%s' path '%s'",
                    siteId, targetPath), e);
        }
    }

    @Override
    public void validateDependencies(final String siteId) {
        retryingDatabaseOperationFacade.retry(() -> dependencyDao.validateDependenciesForSite(siteId));
    }

    @Override
    public boolean isValidDependencySource(final String siteId, final String path) {
        boolean isXml = path.endsWith(DmConstants.XML_PATTERN);
        boolean isCss = path.endsWith(DmConstants.CSS_PATTERN);
        boolean isJs = path.endsWith(DmConstants.JS_PATTERN);
        boolean isTemplate = ContentUtils.matchesPatterns(path, servicesConfig.getRenderingTemplatePatterns(siteId));

        return isXml || isCss || isJs || isTemplate;
    }

    public void setStudioConfiguration(StudioConfiguration studioConfiguration) {
        this.studioConfiguration = studioConfiguration;
    }

    public void setDependencyDao(DependencyDAO dependencyDao) {
        this.dependencyDao = dependencyDao;
    }

    public void setItemServiceInternal(ItemServiceInternal itemServiceInternal) {
        this.itemServiceInternal = itemServiceInternal;
    }

    public void setDependencyResolver(DependencyResolver dependencyResolver) {
        this.dependencyResolver = dependencyResolver;
    }

    public void setServicesConfig(ServicesConfig servicesConfig) {
        this.servicesConfig = servicesConfig;
    }

    public void setGeneralLockService(GeneralLockService generalLockService) {
        this.generalLockService = generalLockService;
    }

    public void setRetryingDatabaseOperationFacade(RetryingDatabaseOperationFacade retryingDatabaseOperationFacade) {
        this.retryingDatabaseOperationFacade = retryingDatabaseOperationFacade;
    }

	public void setPermissionEvaluator(PermissionEvaluator permissionEvaluator) {
		this.permissionEvaluator = permissionEvaluator;
	}

	public void setSecurityService(SecurityService securityService) {
		this.securityService = securityService;
	}
}
