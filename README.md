# JNUC 2024 | Tick-Tock Tech: Strategies for Maximizing Efficiency & Timing for macOS with Jamf Pro

**Presenters:** [Adam Caudill](https://github.com/theadamcraig) • [Adam Williams](https://github.com/Adam24Williams)

---

[Download the presentation](https://github.com/theadamcraig/jnuc2024/raw/main/JNUC%202024%20-%20Tick%20Tock%20Tech.key)

---

### Description

Managing Mac software, security and compliance while creating a good user experience often requires specific timing of multi-step workflows. In this presentation, we will go over the basic options built into Jamf policies, as well as intermediate and advanced workflows centered on managing the timing to ensure all the pieces fit together.

Jamf Admins will learn about the use cases and limitations of Jamf’s basic policy settings, and how to manage the timing of policy executions and configuration profile deployments using various methods. Participants will leave with a better understanding of how to utilize custom triggers, extension attributes, integrations, and scripts to complete tasks in the desired order. This session will be valuable for those looking to improve enrollment workflows, install or remediate security agents that require configuration profiles to be installed beforehand, use integrations such as Tines to populate data promptly, and apply best practices for extension attributes and smart groups to assist with scoping.

We will provide specific examples and scripts that attendees can take home and integrate, as well as insights to increase efficiency. New users to Jamf will gain a comprehensive understanding of how different components work, while seasoned experts may also discover useful new strategies.

---

### Slow Deployment Group Extension Attribute

[Script](https://github.com/theadamcraig/jnuc2024/blob/main/scripts/patch_group%20-%20EA.sh)

We created randomized deployment groups designed for slower controlled deployments.
There is a Patch Group extension attribute that outputs a random number between 1-8, The number changes during an inventory update once a day.
You then create smart groups to match the Patch Group extension attribute for each number.
This will result in each patch group having a random selection of computers that is constantly changing.
You can scope a policy to a patch group and it will go out to about 1/8th of your computers now, and will overtime be scoped to and run on the rest of your computers.
You can also exclude various patch groups for a similar effect.

---

### Add/Remove From Static Group Scripts
