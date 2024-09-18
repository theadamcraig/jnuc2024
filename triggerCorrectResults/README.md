# JNUC-2024
For JNUC 2024 Tick Tock Tech Presentation

## triggerCorrectResults

### The Problem

When triggering a jamf policy with a unix command from another policy, the parent policy will always show completed with a successful exit code.

![trigger_unix_command](https://github.com/theadamcraig/jnuc2024/blob/main/images/trigger_unix_command.png)

This will result in your jamf dashboard showing 100% complete regardless of the actual results.

![policy_fail_artificial_success](https://github.com/theadamcraig/jnuc2024/blob/main/images/trigger_unix_command.png)

If you look at the logs for a policy that triggered a policy with a failure it will show the status as “Completed” and not “Failure” even though when you look at the details it shows “exit code: 1” and “Error running script return code was 1”

![policy_fail_example_results](https://github.com/theadamcraig/jnuc2024/blob/main/images/policy_fail_example_results.png)
![policy_fail_example_log](https://github.com/theadamcraig/jnuc2024/blob/main/images/policy_fail_example_log.png)

This also means that for policies that are triggering other policies the "Automatically Re-Run on Failure" feature effectively does nothing.

![automatically_re-run_on_failure](https://github.com/theadamcraig/jnuc2024/blob/main/images/automatically_re-run_on_failure.png)

### The Solution

Above is [jamf_policy_trigger_correct_results.sh](https://github.com/theadamcraig/jnuc2024/blob/main/triggerCorrectResults/jamf_policy_trigger_correct_results.sh) and 2 scripts that use it as a function.

This script takes the target policy custom trigger as parameter $4, then captures the exit code from that trigger.
It also checks to make sure the result does not contain "No policies were found"

The script then exits with a success only if the targeted policy was run and exited with a successful exit code.

![policy_trigger_correct_results_script](https://github.com/theadamcraig/jnuc2024/blob/main/images/policy_trigger_correct_results_script.png)

The main script is ready to go and can be used as is with a parameter of the targeted policy.

![policy_trigger_correct_results_parameter](https://github.com/theadamcraig/jnuc2024/blob/main/images/policy_trigger_correct_results_parameter.png)

You can also add this as a function into your own scripts. There are two scripts that do this as an example:
 - [chrome_update_if_closed.sh](https://github.com/theadamcraig/jnuc2024/blob/main/triggerCorrectResults/chrome_update_if_closed.sh)
 - [chrome_check_initial_prefs.sh](https://github.com/theadamcraig/jnuc2024/blob/main/triggerCorrectResults/chrome_check_initial_prefs.sh)
