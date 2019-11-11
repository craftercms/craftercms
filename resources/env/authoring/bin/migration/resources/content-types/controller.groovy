/*
 * Copyright (C) 2007-2019 Crafter Software Corporation. All Rights Reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import scripts.libs.CommonLifecycleApi

def contentLifecycleParams =[:]
contentLifecycleParams.site = site
contentLifecycleParams.path = path
contentLifecycleParams.user = user
contentLifecycleParams.contentType = contentType
contentLifecycleParams.contentLifecycleOperation = contentLifecycleOperation
contentLifecycleParams.contentLoader = contentLoader
contentLifecycleParams.applicationContext = applicationContext

def controller = new CommonLifecycleApi(contentLifecycleParams)
controller.execute()
