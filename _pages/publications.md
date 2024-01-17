---
layout: page
permalink: /publications/
title: Publications
description: 
years: [2023, 2024]
nav: true
---
\* indicates equal contributioncon.

#### Preprints

<div class="publications">
{% for y in page.years %}
  {% bibliography -f preprints -q @*[year={{y}}]* %}
{% endfor %}
</div>

#### Papers

<div class="publications">

{% for y in page.years %}

<div>{{y}}</div>
  {% bibliography -f conferences -q @*[year={{y}}]* %}
{% endfor %}

</div>
