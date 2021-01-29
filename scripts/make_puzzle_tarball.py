import os
import subprocess
import json
import time


pwd = os.getcwd()

container_id = subprocess.check_output(["docker", "run", "-v", f"{pwd}:/puzzle", "-td",  "jvns/game:base", "/bin/bash"])
container_id = container_id.decode("utf-8").strip()
container_json = subprocess.check_output(["docker", "inspect", container_id])
properties = json.loads(container_json)

upperdir = properties[0]['GraphDriver']['Data']['UpperDir']

subprocess.check_call(["docker", "exec", container_id, "bash", "/puzzle/build.sh"])
subprocess.check_call(["sudo", "tar", "-C", upperdir, "--exclude=puzzle", "--xattrs", "-cf", "puzzle.tar", '.'])

subprocess.check_call(["docker", "kill", container_id])
