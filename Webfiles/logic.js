const init_synthesis_task_api = "<API_URL>/TTS_initializeTask";
const fetch_url_api = "<API_URL>/TTS_StepFunction";

const speech_text_form = document.getElementById('speech-text-form')
const response_details_1 = document.getElementById('response-details-1');
const response_details_2 = document.getElementById('response-details-2');
const response_box = document.getElementById('response-box');


async function initializeTask() {
    const input_text = document.getElementById('input-text');
    input_text.disabled = true;
    console.log('Requesting Task ID from AWS Polly');
    console.log(`Requested Text: ${input_text.value} from ${init_synthesis_task_api}`);
    response_details_1.textContent = 'Fetching audio URL...';
    const request = {method: 'POST', body: input_text.value};
    try {var polly_task = await fetch(init_synthesis_task_api, request)
        .then(response => response.json())
        .then(response => polly_task = response);
    } catch {
        throw new Error('Could not communicate with network.')
    }
    try {
        const task_id = polly_task['body']['taskId'];
        console.log(task_id);
        return task_id;
    } catch (error) {
        console.log(`Unexpected error ${error}`);
        response_details_1.textContent = "Task failed >:( Try again later.";
    }
}

async function retrieveTask(task_id, sleep_time=1000) {
    const input_text = document.getElementById('input-text');
    input_text.disabled = true;
    console.log(`Trying again in ${sleep_time}ms`);
    if (sleep_time > 10000) {
        throw new Error('Timeout');
    }
    const payload = {mode: "cors", headers: {"x-tts-taskid": task_id}};
    console.log(payload);
        var fetch_task = await fetch(fetch_url_api, payload)
        .then(response => {
            if (response.status === 400) {
                throw new Error('FetchTask API did not receive or could not interpret the contents of the "x-tts-taskid" header.');
            } else if (response.status === 404) {
                throw new Error('Invalid Task ID');
            } else if (response.status === 500) {
                throw new Error('FetchTask API is not working right now. Is the server-side handler working correctly?');
            } else if (response.status === 503) {
                throw new Error('Polly cold not finish the synthesis task. Task cancelled.');
            } else if (response.status === 302) {
                console.log('Synthesis task in progress. Attempting to retrieve again.');
                setTimeout(() => retrieveTask(task_id, (sleep_time + 1000)), sleep_time);
            } else if (response.status === 200) {
                console.log('Task retrieved successfully');
                response = response.text()
                    .then(response => print_response(response));
            } else {
                console.log(`Unexpected response received. Trying again.`);
                console.log(`CODE: ${response.status}, MESSAGE: ${response.statusText}`);
                setTimeout(() => retrieveTask(task_id, (sleep_time + 1000)), sleep_time);   // Attempt retrieval again w/ exponential backoff.
            }
        })
        .catch(error => {
            console.log(`Unable to communicate with network. Trying again.`);
            console.log(`CODE: ${error.status}, MESSAGE: ${error.statusText}`);
            setTimeout(() => retrieveTask(task_id, (sleep_time + 1000)), sleep_time);
        });
}

function print_response(url) {
    response_box.href = url;
    response_details_1.textContent = 'Task complete! Click the link below to listen to the task in the browser.';
    response_details_2.textContent = 'Or right click > "Save link as..." to save audio.';
    response_box.textContent = 'View audio file';
}

speech_text_form.addEventListener('submit', async (event) => {
    var proceed = true;
    event.preventDefault();
    const task_id = await initializeTask()
        .catch(error => {
            response_details_1.textContent = `ERROR: ${error.message}`;
            proceed = false;
        });
    if (!proceed) {
        return;
    }
    console.log(`Task ID: ${task_id}`);
    console.log(`Fetching audio`);
    await retrieveTask(task_id)
        .catch(error => response_details_1.textContent = error.message);
});