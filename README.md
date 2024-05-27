# BioDT: Forest Biodiversity Dynamics

# Prototype Digital Twin (pDT) for Forest Biodiversity under Different Management and Climate Change Scenarios

## Overview

- **Title:** Forest biodiversity under different management and climate change scenarios: Implications for adaptive forest management
- **Responsible Organization:** University of Jyväskylä
- **pDT Leader:** Bekir Afsar
- **pDT Participants:** Otso Ovaskainen, Tuomas Rossi, Martijn Versluijs, Kyle Eyvindson

## Key Scientific Questions

- **Open Scientific Questions:** How will forest biodiversity change under different forestry and climate change scenarios, and how can these predictions be utilized in conservation and adaptive forest management?
- **Research Questions:** How to best utilize available data to make reliable predictions and decisions addressing the key open scientific questions?

## Purpose

This pDT aims to investigate the impact of different forest management strategies and climate change scenarios on forests and biodiversity. The goal is to identify the most appropriate treatment option that improves biodiversity for a specific forest stand under various climate scenarios.

## Scope

Initial focus: Forests and bird species in Finland. Future consideration for expansion to other European countries and different species.

## Methodologies

- **Forest Simulations:** Under different management options and climate change scenarios.
- **Biodiversity Models:** Relating species dynamics to environmental conditions.
- **Multiobjective Optimization:** Identifying the most appropriate forest management option considering ecological, social, and economic objectives, climate change scenarios, and stakeholder preferences.
- **Decision-Making:** Decide on the most preferred management option based on stakeholder preferences and identified objectives.

## Models/Workflows:

1. **Replica of the Forest:**
   - Forest simulations conducted with LANDIS-II PnET-Succession extension V 4.0.1.
   - LANDIS-II: a landscape model designed to simulate forest succession and disturbances.
   - [LANDIS-II Home Page](https://www.landis-ii.org/home)
   - Programming Language: C#
   - Completely open-source with extensive documentation [GitHub](https://github.com/LANDIS-II-Foundation).
   - List of extensions available [here](https://www.landis-ii.org/extensions).
   
2. **Replica of the Species Living in the Forest:**
   - Biodiversity modeling conducted with the joint species distribution model (HMSC).
   - HMSC: a model-based approach for analyzing community ecological data.
   - [HMSC Home Page](https://www.helsinki.fi/en/researchgroups/statistical-ecology/software/hmsc)
   - Programming Language: R
   - HSMC R-package available on [CRAN](https://cran.r-project.org/web/packages/Hmsc/index.html), and the development version can be found on [GitHub](https://github.com/hmsc-r/HMSC).
   
3. **Interactive Multiobjective Optimization:**
   - Digital Twin Application: Finding the most appropriate forest management strategy.
   - Decision-making process using existing interactive multiobjective optimization methods iteratively. The DESDEO framework is used for decision-making.
   - [DESDEO Home Page](https://desdeo.it.jyu.fi/)
   - Programming Language: Python
   - The development version can be found on [GitHub](https://github.com/industrial-optimization-group/DESDEO).

