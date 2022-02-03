---
id: visual-conceptualization-of-test-impact
uuid: generate
title: 'Tests, continuous improvement '
author: Juan Antonio Nepormoseno Rosales
category: tech
date: 2022-02-...
last-update: 2022-02-...
abstract: asdasdas
---

## Context and cranes

Imagine an app. This app is a marketplace that enables origami creators to sell their craft to interested buyers. Let's call this app Glovigami (other than this joke, everything in the article is fictional data. Any resemblance to reality is mere coincidence).

This app has 3 major modules to it: the creators and products list, the payment and the order management (track, cancel/return).

!\[ products | payment | order mgmt ]

We release the first version of this app to the store after an extensive manual test that covers all main flows and the edge cases for critical features. It works pretty well, but over time we receive some small impact bug reports from users and testers. Since we review them on a case by case basis we don't see any pattern to the issues. But we fix them, so our users are happy.

Inevitably, some major incidents that result in creators losing money occur. The development team gets together for a postmortem and everyone agrees they need more automated testing. The failing cases get some tests and everyone leaves happy, only for another incident to happen next month.

## Measurement and the BBEG

If we try to map the issues found during acceptance and by users, we might find something like this:

\[ 4 | 9 | 5 ]

Even though the issue distribution might seem random, if we count the issues per module we will find something else: the payment module has the same amount as the product and order management modules combines. So, if you had to guess what will cause the next big incident, where will you bet? (tip: my money would be on the payment module)

This is a very simple heuristic, but it summarizes an important concept about quality: **defects cluster together**. Or put another way, a small number of components is usually responsible for most of the failures.

---

The reasons can be wildly different in each case and there are an uncountable amount why a component might fail:

- Maybe the code is ridden with tech debt and it's difficult to keep changes small and understandable.
- Maybe there aren't any regresion tests to prevents us from breaking old features.
- Maybe the component was designed to solve a problem, but the focus and scope changed in the middle of development and we need to work with outdated abstractions.
- Maybe the team that owns that component was formed recently, so they have organization problems.
- Maybe the team has external communication issues, so when they need to integrate their components with other teams', problems and mismatches arise.
- Maybe this component is just the one that sees more usage, so just by statistics we have more users affected by its issues.

In any case, those issues are important and should be prevented. QA can come in any of those points. From writing lint rules, integration or regression tests, to helping their team define ways to work that mitigate internal and external friction. The key is enabling iteration on those checks. Lint rules and tests can be updated, processes can be refined... and

---

## Divide and conquer

\[ 22% | 50% | 27% ]

With this new way of visualizing the issues, we can measure a module's risk of being affected by an issue. It enables us to focus on the component with highest risk (the payment module, in this case) so we can start preventing those issues.

So we investigate this component and increase its coverage. We add unit tests, integration tests to prevent existing features from breaking, and we even add some non-functional tests and monkey testing to detect new issues. With this, we are reducing the risk of being impacted by an issue.

\[ 22% | 25% |/2/5/%/| 27%]

In this example, we reduced the risk by half. There's a 25% chance that an issue gets detected by our automated checks before it even gets in the main branch. These tests are acting like a shield against bugs. In a way, they are reducing the surface area of "uncovered module" that can be impacted by an issue.

If we re-calculate the risk for the uncovered modules, this is the new risk for each of them:

\[ 30% | 33% |//0/%//| 37% ]

This points to the payment module having a lower risk than the order management module after our changes. That's great!

## Continuous improvement

Over the next few weeks we keep track of incoming bug reports, crashes, etc. This way we get new data that we use to verify our assumption. If the payment module keeps being affected by more issues than the rest, we might need to re-think our testing strategy. There might be some edge case or integration we might have forgotten (_or ignored_...). But if the other modules start getting more attention, that probably means we were right. The important part is we established **a feedback loop** that wee can use **to measure and improve our app's quality**.

Unintuitively, the more failing tests we have, the healthier our app will be. Granted, if we're fixing issues we find. (but up to a point, we can't have tests block us)

