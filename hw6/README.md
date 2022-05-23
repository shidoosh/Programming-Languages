# Homework 6. Language bindings for TensorFlow


## Motivation
Following up on the project, suppose you are trying to run an application server proxy herd on a large set of virtual machines. Your application uses machine learning algorithms and relies heavily on TensorFlow. You've built a prototype using Python and it runs as well as could be expected on large queries.

However, your application is unusual in that it handles many small queries, that create and/or execute models that are tiny by machine-learning standards. Although typical TensorFlow applications are bottlenecked inside C++ or CUDA code (e.g., in the Eigen or cuDNN libraries), when you benchmark your application you discover that it's spending most of its time executing Python code to set up your models.

Your boss suggests that a way to speed up performance would be to convert your application's Python code to some other language, and then use that instead of Python. You want to keep TensorFlow and the ability to prototype with Python, but you also want your application to run efficiently.

## Assignment
Review TensorFlow Architecture and TensorFlow in other languages, and consider three other languages that are plausible candidates for implementing your application: (1) Java (see bindings), (2) OCaml (see bindings), and (3) a language taken from the following list.

Crystal (see bindings)
F# (see bindings)
Vala (see bindings)
Do some research on your three languages and support software as a potential platform. Your research should include an examination of the language and system documentation to help determine whether it would be effective. We want an alternative that supports event-driven servers well, such as the project servers using Python's asyncio.

Unlike the project, we are not expecting working prototypes, though prototypes are welcome.

Write an executive summary that compares the three alternate approaches to each other and to Python. The summary should be in 10-point font or larger and should be at most three pages. You can put references and appendixes in later pages, if there's not enough room on four pages: the appendixes should contain any source code or diagrams. Your summary should focus on the technologies' effects on ease of use, flexibility, generality, performance, reliability; thie idea is to explore the most-important technical challenges in doing the proposed rewrite. The summary should be suitable for software executives, that is, for readers who have some expertise in software, particularly in managing software developers, but who are not experts in Java or OCaml or your chosen language. Please keep the resources for written reports and oral presentations in mind, particularly its rubrics and its advice for citations to sources that you consulted.
