---
layout: page
title: VLARLKit
description: An elegant and researcher-friendly RL library for Vision-Language-Action (VLA) models.
img: assets/img/projects/vlarlkit_logo.png
importance: 1
category: work
---


<div class="row justify-content-sm-center" >
    <div class="col-sm mt-3 mt-md-0">
        {% include figure.html path="assets/img/projects/vlarlkit_logo.png" title="VLARLKit" class="img-fluid rounded z-depth-0" %}
    </div>
</div>

- Github repo: [VLARLKit](https://github.com/VLARLKit/VLARLKit). [![VLARLKit repo](https://img.shields.io/github/stars/VLARLKit/VLARLKit?style=social)](https://github.com/VLARLKit/VLARLKit)

VLARLKit is a PyTorch-based reinforcement learning library tailored for Vision-Language-Action (VLA) models. It is designed to be friendly and convenient for researchers, with the following features:

- Simple and clear implementation, with cleanly separated policy, rollout, runner, and model layers, easy to read, modify, and extend
- Environment-decoupled architecture, environments run as independent processes via ZMQ, eliminating dependency conflicts between different benchmark simulators
- Async off-policy training, supports asynchronous off-policy training, enabling non-blocking data collection alongside model updates

### Supported components
- RL Algorithms
    - [Proximal Policy Optimization (PPO)](https://arxiv.org/abs/1707.06347) (on-policy)
    - [Diffusion Steering via Reinforcement Learning (DSRL)](https://arxiv.org/pdf/2506.15799) (off-policy)
    - [RL Token (RLT)](https://www.pi.website/download/rlt.pdf) (off-policy)
- Base Models
    - [π₀.₅](https://github.com/Physical-Intelligence/openpi)
- Benchmarks
    - [LIBERO](https://github.com/Lifelong-Robot-Learning/LIBERO)
    - [ManiSkill](https://github.com/haosulab/ManiSkill)
