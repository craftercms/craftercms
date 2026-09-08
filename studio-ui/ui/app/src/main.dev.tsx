import React, { useEffect, useState } from 'react';
import { createRoot } from 'react-dom/client';
import CrafterCMSNextBridge from './components/CrafterCMSNextBridge';
import { useDispatch } from 'react-redux';
import { useIntl } from 'react-intl';
import useActiveSiteId from './hooks/useActiveSiteId';
import BrowseFilesDialog from './components/BrowseFilesDialog';
import { processPopulateExpression, validateDatePopulateExpression } from './components/FormsEngine/lib/controlHelpers';
import TextField from '@mui/material/TextField';
import Box from '@mui/material/Box';
import Preview from './pages/Preview';
import Global from './pages/Global';
import { LoadingState } from './components';
import { Skeleton } from '@mui/material';

function App() {
	const dispatch = useDispatch();
	const { formatMessage } = useIntl();
	const siteId = useActiveSiteId();
	const [item, setItem] = useState(null);
	const [exp, setExp] = useState('{now}');
	const [processed, setProcessed] = useState(null);

	useEffect(() => {
		// showSingleFileUploadDialog({
		// 	dispatch,
		// 	siteId,
		// 	path: '/static-assets/files/',
		// 	// onFileAdded: (file) => {
		// 	// 	console.log('file', file);
		// 	// },
		// 	onUploadComplete: (result) => {
		// 		console.log('result', result);
		// 	}
		// });
		// dispatch(
		// 	pushDialog({
		// 		component: createComponentId('ImageEditorDialog'),
		// 		props: {
		// 			path: '/static-assets/images/book-woman-pic.jpg',
		// 			writeContent: true,
		// 			restrictions
		// 			// modes: ['rotate']
		// 		}
		// 	})
		// );

		// e.g. now+2d, now-3weeks, now+1years, now-4hours, now+30minutes
		const processed = processPopulateExpression({
			// expression: '{friday} 09:00:00',
			// expression: '{now+2d} 09:00:00',
			// expression: '{now+2d}',
			// expression: '{now+1years}',
			// expression: '{thursday}',
			expression: exp,
			validatePopulateExpression: validateDatePopulateExpression,
			allowPastDate: false
		});

		setProcessed(processed);
		// console.log('exp', processed);

		// fetchContentItem(siteId, '/site/website/index.xml').subscribe((item) => {
		// 	setItem(item);
		// });
	}, [dispatch, exp]);

	return (
		<>
			<Box sx={{ p: 2 }}>
				<TextField
					label="Exp"
					variant="outlined"
					value={exp}
					onChange={(event: React.ChangeEvent<HTMLInputElement>) => {
						setExp(event.target.value);
					}}
				/>
				<div>{processed?.toString()}</div>
			</Box>
			{/*<ContentTypeManagement />*/}
			{/*<FormsEngine update={{ path: '/site/website/index.xml' }} />*/}
			{/*<FormsEngine update={{ path: '/site/website/tests/index.xml' }} />*/}
			{/*<FormsEngine update={{ path: '/site/components/features/4be0a368-783c-8f73-7469-63a62636bd4c.xml' }} />*/}
			{/* <FormsEngine update={{ path: '/site/website/asd/index.xml' }} />*/}
			{/* <SingleFileUpload
				site={siteId}
				path="/static-assets/images"
				onFileAdded={(file, uppy, callback) => {
					const data = file.data; // is a Blob instance
					const url = URL.createObjectURL(data);
					const image = new Image();
					image.src = url;
					image.onload = () => {
						if (!imageMeetRestrictions(image, restrictions)) {
							const dialogId = nanoid();
							dispatch(
								pushDialog({
									id: dialogId,
									component: createComponentId('ImageEditorDialog'),
									props: {
										path: url,
										restrictions,
										onCrop: (blob: Blob) => {
											dispatch(popDialog({ id: dialogId }));
											uppy.setFileState(file.id, {
												...file.meta,
												source: 'crop',
												name: file.name,
												type: blob.type,
												data: blob
											});
											callback?.();
										}
									}
								})
							);
						} else {
							callback?.();
						}
					};
				}}
			/>*/}
			{/*<BrowseExternalAssetDialog
				path="/"
				profileId="s3-default"
				open={true}
				multiSelect
				preselectedPaths={['/remote-assets/s3/s3-default/nature-backgrounds.jpg']}
				onSuccess={(selection) => {
					console.log('selection', selection);
				}}
			/>*/}
			{/* webdav */}
			{/* <BrowseExternalAssetDialog
				path="/"
				profileId="webdav-default"
				open={false}
				profileType="webdav"
				// multiSelect
				// preselectedPaths={['/remote-assets/s3/s3-default/nature-backgrounds.jpg']}
				onSuccess={(selection) => {
					console.log('selection', selection);
				}}
			/>*/}
			<BrowseFilesDialog
				path="/static-assets/images"
				open={false}
				multiSelect
				preselectedPaths={['/static-assets/images/get-in-shape-pic.jpg']}
				onSuccess={(selection) => {
					console.log('selection', selection);
				}}
			/>
			{/* <ExternalAssetUploadDialog onClose={() => {}} open={false} path="/" profileId="s3-default" />
			<ExternalAssetUploadDialog
				onClose={() => {
					console.log('close!');
				}}
				open={false}
				path="/"S
				profileId="webdav-default"
				profileType="webdav"
			/>*/}
			{/* <SingleFileUploadDialog onClose={() => {}} site={siteId} path={'/stati-assets/images'} open={true} />*/}
			{/* <LoadingState /> */}
		</>
	);
}

createRoot(document.getElementById('root')).render(
	<CrafterCMSNextBridge>
		{/* <App /> */}
		<Preview />
		{/* <Login /> */}
		{/* <Global passwordRequirementsMinComplexity={3} footerHtml="" /> */}
	</CrafterCMSNextBridge>
);
