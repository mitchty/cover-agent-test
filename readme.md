# Python Cover Agent Example

Very basic demo in getting a contrived python file coverage increase from cover-agent.

The approach is generally intended to be used in a CI/CD environment e.g. in Github actions etc...

Strategy would be a developer makes changes, creates a basic test, in this case in python pytest. Commits, pushes to a pull request. Then cover agent would take over and talk to open webui's ollama instance.

Note you can run cover agent from anywhere as long as you have api access to the ollama api so this can also be ran from a workstation. But to save on setup of cover agent this is omitted.

[[file:ci.sh][Link to mock CI script]]
[[file:calc.py][Our python source to be tested]]
[[file:test_calc.py][Pytest test file for our 4 functions]]

Our test command is using pytest, and pytest-cov to provide coverage data for per line source.

```sh
pytest --cov=. --cov-report=xml --cov-report=term
```

Then to simulate what work a CI system such as Jenkins, Drone, etc.. would do in running cover agent on the local git checkout, we run ci.sh.

```sh
./ci.sh
```
