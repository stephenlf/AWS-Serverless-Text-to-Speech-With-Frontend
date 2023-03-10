# AWS-Serverless-Text-to-Speech-With-Frontend
This repo contains the code and instructions necessary for creating a simple, serverless text-to-speech application using AWS services. I also provide a simple HTML/JavaScript frontend for interfacing with the application.

## Architectural overview
Text-to-speech functionality is powered by [Amazon Polly](https://aws.amazon.com/polly/). Text requests are sent to an API Gateway API in the form of an HTTP POST payload. This payload gets parsed by a Lambda function before being submitted to Polly to synthesize the audio file.

After the request has been made, the returned Synthesis Task ID is sent back to the API (down a different route) to see if the task is complete. If so, an S3 object URL pointing to the synthesized audio file is given to the user. Otherwise, the script waits a moment then tries again until the task is complete, an error is thrown, or the task times out. Request intervals increase linearly between tries to limit throttling in a linear [backoff model](https://docs.aws.amazon.com/general/latest/gr/api-retries.html).

All of the scripts in the frontend logic are run asynchronously.

<details><Summary>See the architectural diagram</summary>
![Architectural diagram of this project](/Assets/Architectural-diagram.png)
</details>
