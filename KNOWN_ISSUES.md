# Known issues
 |Location|Description
 |---|---|
 Webfiles/logic.js.103|`.catch()` block fails to capture errors thrown by nested calls to `retrieveTask()` in line 63. Will solve by refactoring `retrieveTask()` as a Promise constructor.
 Webfiles/logic.js|Code could be made more beautiful and clear.
 API Calls|API Calls and audio files are note secured. Consider making audio files accessible only to the person who requested them and/or using some sort of authentication (like [Cognito identity pools with anonymous access](https://docs.aws.amazon.com/location/latest/developerguide/authenticating-using-cognito.html)) to control the use of this tool.
### Planned features
* Make frontend beautiful
* Initialize Lambda functions from Terraform
* Initialize the static_website and synthesis_task_dump S3 buckets in Terraform
* [MAYBE] Zip Lambda source files with Terraform
* Trigger Step Function with API gateway to delete audio files after ~5 minutes. Refactor API gateway to trigger Lambda through this Step Function.
