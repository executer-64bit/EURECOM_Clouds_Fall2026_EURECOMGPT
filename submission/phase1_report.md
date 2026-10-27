# Phase 1 — Comparison Report

## 1. Setup facts

**Your image size**, in MB, from Artifact Registry:

<!--answer:image_size_mb-->
48.97
<!--/answer-->

The size for image of VM and Cloud Run is 48.97MB because VM and echo-bot execute the same image Docker. Whereas Cloud Function executes the source code (main.py) with the size of its artifact.

**The custom VPC and subnet you created** (names only):

<!--answer:vpc_name-->
echo-net
<!--/answer-->

<!--answer:subnet_name-->
echo-subnet
<!--/answer-->

---

## 2. Measurements

| Platform | Cold (ms) | Warm median (ms) |
|---|---:|---:|
| IaaS VM | <!--answer:vm_cold_ms-->234.6<!--/answer--> | <!--answer:vm_warm_median_ms-->211.1<!--/answer--> |
| Cloud Run | <!--answer:cloudrun_cold_ms-->697.9<!--/answer--> | <!--answer:cloudrun_warm_median_ms-->636.8<!--/answer--> |
| Cloud Function | <!--answer:function_cold_ms-->137.5<!--/answer--> | <!--answer:function_warm_median_ms-->638.2<!--/answer--> |

### Warm latency distribution

The following histogram groups the 20 warm requests and cold requests per platform into latency ranges. Each `#` represents one warm request and X a cold one.

<!--answer:latency_plot-->
```text
Latency (ms)   VM cold/warm           Cloud Run cold/warm      Function cold/warm
100–199        -                      -  #####                 X  ######
200–299        X  #################### -  -                    -  -
300–399        -                      -  -                     -  -
400–499        -                      -  -                     -  -
500–599        -                      -  -                     -  -
600–699        -                      X  ###############       -  ###########
700–799        -                      -  -                     -  ###
```
<!--/answer-->

The VM's first measured request was 234.6 ms, while all 20 warm requests fell between 210.2 and 215.0 ms. Cloud Run's first measured request was 697.9 ms; its warm requests split between 5 requests in the 100–199 ms and 15 in the 600–699 ms. The Function's first measured request was 137.5 ms; its warm requests included 6 requests in the 100–199 ms, 11 in the 600–699 ms, and 3 in the 700–799 ms. Although Cloud Run and the Function have similar warm medians (636.8 ms and 638.2 ms), their individual request times vary considerably. The first measured request is not necessarily a true cold start because the test did not force either service to scale to zero.

---

## 3. Per-platform analysis

**Scaling behaviour** Imagine requests arriving one at a time, then ten at once, then a
hundred. For each of the three platforms, answer concretely:

- Does anything get created automatically to absorb the load — and if so, *what* exactly?
  (One platform here creates nothing at all.)
- What is the hard limit, and where does it come from — a flag you passed yourself, or the
  size of the machine you picked?

(~80 words. Your `--machine-type=e2-micro` and `--max-instances=3` are both concrete answers
to the second question.)

<!--answer:scaling_behaviour-->
The VM does not automatically create additional machines to absorb traffic. All requests share one `e2-micro` instance, so its CPU and memory capacity limit throughput. Cloud Run automatically adjusts the number of container instances in response to demand; this deployment was configured with a minimum of zero and a maximum of three instances. The second-generation Cloud Function also scales its managed execution instances automatically. No explicit maximum instance count was supplied in the function deployment command, so its effective limit depends on platform configuration and project quotas rather than a maximum flag set in that command.
<!--/answer-->

**Deployment effort** What did you have to build, configure and maintain to get each of the
three running? (~100 words)

<!--answer:deployment_effort-->
For the VM, I built a Docker image, configured Artifact Registry, created a custom VPC and subnet, configured firewall rules, provisioned an `e2-micro` VM, installed Docker, authenticated to the registry, and started the container. I also had to manage the VM and network resources. For Cloud Run, I built and pushed the container image and deployed it as a managed service, configuring scaling and public access. For the second-generation Cloud Function, I deployed Python source code with a function-specific command and configured an HTTP trigger and unauthenticated access. Its managed build initially required resolving account permissions. Overall, the VM required the more configuration, while the serverless platforms reduced management work.
<!--/answer-->

---

## 4. Why do two of your three numbers look alike?

With Cloud Run and your Function both deployed, run `gcloud run services list` and paste the complete output here, unedited:

<!--answer:run_services_list-->
```text
Your active configuration is: [cloudshell-11136]

SERVICE: echo
REGION: us-central1
URL: https://echo-779202919300.us-central1.run.app
LAST DEPLOYED BY: service-779202919300@gcf-admin-robot.iam.gserviceaccount.com
LAST DEPLOYED AT: 2026-10-24T12:52:12.128117Z


SERVICE: echo-bot
REGION: us-central1
URL: https://echo-bot-779202919300.us-central1.run.app
LAST DEPLOYED BY: sergioramos10010@gmail.com
LAST DEPLOYED AT: 2026-10-24T12:41:35.551486Z
```
<!--/answer-->

Now explain what that output tells you about how your Function is actually being run, why its cold start resembles Cloud Run's so closely, and what — if anything — genuinely differs between the two deployment paths.

<!--answer:convergence_explanation-->
The output lists two Cloud Run services: echo-bot, deployed directly to Cloud Run, and echo, created by the second-generation Cloud Function deployment. This shows that the Function is not running on a completely separate execution platform: second-generation Cloud Functions use Cloud Run infrastructure to run their underlying service. This shared infrastructure helps explain why their warm median latencies are very similar (636.8 ms for Cloud Run and 638.2 ms for the Function). However, their measured first-request latencies were different: 697.9 ms for Cloud Run and 137.5 ms for the Function. These measurements do not prove that either service experienced a genuine cold start, because the test did not force the services to scale to zero before measuring. The deployment paths also differ. Cloud Run deploys a container image directly, while Cloud Functions deploys source code through a managed build process with a specified runtime and an HTTP
<!--/answer-->
