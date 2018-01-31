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
