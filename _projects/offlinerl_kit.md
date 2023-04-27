---
layout: page
title: OfflineRL-Kit
description: An elegant PyTorch offline reinforcement learning library.
img: assets/img/projects/offlinerl_kit_logo.png
importance: 1
category: work
---


<div class="row justify-content-sm-center" >
    <div class="col-sm mt-3 mt-md-0">
        {% include figure.html path="assets/img/projects/offlinerl_kit_logo.png" title="OfflineRL-Kit" class="img-fluid rounded z-depth-0" %}
    </div>
</div>

- Github repo: [OfflineRL-Kit](https://github.com/yihaosun1124/OfflineRL-Kit). [![OfflineRL-Kit repo](https://img.shields.io/github/stars/yihaosun1124/OfflineRL-Kit?style=social)](https://github.com/yihaosun1124/OfflineRL-Kit)

OfflineRL-Kit is an offline reinforcement learning library based on pure PyTorch. This library has some features which are friendly and convenient for researchers, including:

- Elegant framework, the code structure is very clear and easy to use
- State-of-the-art offline RL algorithms, including model-free and model-based approaches
- High scalability, you can build your new algorithm with few lines of code based on the components in our library
- Support parallel tuning, very convenient for researchers
- Clear and powerful log system, easy to manage experiments

### Supported algorithms
- Model-free
    - [Conservative Q-Learning (CQL)](https://arxiv.org/abs/2006.04779)
    - [TD3+BC](https://arxiv.org/abs/2106.06860)
    - [Implicit Q-Learning (IQL)](https://arxiv.org/abs/2110.06169)
    - [Ensemble-Diversified Actor Critic (EDAC)](https://arxiv.org/abs/2110.01548)
    - [Mildly Conservative Q-Learning (MCQ)](https://arxiv.org/abs/2206.04745)
- Model-based
    - [Model-based Offline Policy Optimization (MOPO)](https://arxiv.org/abs/2005.13239)
    - [Conservative Offline Model-Based Policy Optimization (COMBO)](https://arxiv.org/abs/2102.08363)
    - [Robust Adversarial Model-Based Offline Reinforcement Learning (RAMBO)](https://arxiv.org/abs/2204.12581)