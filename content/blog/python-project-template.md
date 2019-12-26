---
title: "A template for Python projects"
date: 2019-12-26T12:00:00+01:00
draft: false
image: "images/software-engineering-posts/python-project-template-cover.jpg"
description: "a template available on github to start new python projects"
categories:
  - "Software Engineering"
tags:
  - "Python"
type: "featured"
---

I am a lazy person. Every time I find myself doing the same thing more than twice, I automate it. It requires effort at first, but it is worth it in the long run. Starting a new Python project is one of those things, and today I wanna share with you my blueprint for it. You can find the [full template on github](https://github.com/gabrieleangeletti/python-package-template). This setup is a good starting point for a small to medium-sized codebase and it does the common stuff:

* Set up the development environment
* Manage dependencies
* Format your code
* Run linting, static type-checking and unit-testing

In the next sections I will describe how these things are set up in the template. Note that a few things are missing, which I'm planning to add next:

* A deployment script
* A continuous integration pipeline

### Managing python versions - Pyenv

Managing multiple versions of python, or of any language for that matter, is a painful experience, for many reasons: the system version that you can't touch, the 2 vs 3 nightmares, two different projects that require different interpreters and so on. [Pyenv](https://github.com/pyenv/pyenv) solves this problem: it is a version management tool that makes your life easier in a lot of ways. If you come from the Javascript / Node world, the tool is similar to the popular [n](https://github.com/tj/n).

With `pyenv` you can easily:

* Install a new version: `pyenv install X.Y.Z`
* Set a version as global: `pyenv global X.Y.Z`
* Set a version for the current shell by overriding the `PYENV_VERSION` environment variable
* Set an application-specific version by creating a `.python-version` file

### Managing dependencies - Pipfile

If dealing with versions is painful, dealing with dependencies is even worse. Any non-trivial application depends on external packages, which in turn depend on other packages, and ensuring everyone gets the same versions can be rather challenging. In the python world, dependencies have been traditionally managed through the `requirements.txt` file. It contains the packages your app needs, optionally with the required versions. The problem is that this file doesn't handle *recursive* dependencies, that is the dependencies of your app's dependencies. [Pipfile](https://github.com/pypa/pipfile) is a new specification that aims to solve this. It has many advantages over requirements. The biggest one by far is *deterministic builds*. `Pipfile` and its partner `Pipfile.lock` contain all the information needed to install the *same exact environment* anywhere.

Let's make an example. Consider the following scenario: our application `Ninja ducks` depends on version `1.2.3` of package `ninja`, which in turn depends on another package called `requests`.

#### Example - requirements.txt

A `requirements.txt` file would look like this:

```
ninja==1.2.3
```

When running `pip install -r requirements.txt`, we install version `1.2.3` of `ninja`, because that's what the requirements say, and version `2.7.9` of `requests`, because that was the latest public version at the time. A couple of weeks later we deploy the application, but in the meantime `requests` was upgraded to `3.0.0`. If `ninja` was using a feature from `requests` that has been changed or removed, our application will crash. We could fix this problem by adding `requests` to the requirements file, but you can see for yourself that this solution doesn't really scale.

#### Example - Pipfile

A `Pipfile` instead would look something like this:

```
[[source]]
url = "https://pypi.org/simple"
verify_ssl = true
name = "pypi"

[packages]
ninja = {version = "==1.2.3"}
```

From this we can run `pipenv lock` to generate a `Pipfile.lock`:

```
{
    "_meta": {
        "hash": {
            "sha256": "2aa45098c4b406ce8fccc5d6abfd7fcfd0e39cc6b6ef8529d1e14882d86f007c"
        },
        "pipfile-spec": 6,
        "sources": [
            {
                "name": "pypi",
                "url": "https://pypi.org/simple",
                "verify_ssl": true
            }
        ]
    },
    "default": {
        "ninja": {
            "hashes": [
                "sha256:37228cda29411948b422fae072f57e31d3396d2ee1c9783775980ee9c9990af6",
                "sha256:58587dd4dc3daefad0487f6d9ae32b4542b185e1c36db6993290e7c41ca2b47c"
            ],
            "version": "==1.2.3"
        },
        "requests": {
            "hashes": [
                "sha256:9e5896d1372858f8dd3344faf4e5014d21849c756c8d5701f78f8a103b372d92",
                "sha256:d8b24664561d0d34ddfaec54636d502d7cea6e29c3eaf68f3df6180863e2166e"
            ],
            "version": "==2.7.9"
        }
    }
}
```

As you can see, `requests` is there, even if we didn't mention it anywhere in our `Pipfile`. That's because `Pipfile` handles recursive dependencies through the `Pipfile.lock` file. During deploy, when we run `pipenv install --deploy` to install dependencies, the correct version of `requests` will be installed, regardless of the latest version available in the public registry.

* Note 1: in the above I used a couple of `pipenv` commmands, which is the [reference implementation](https://pipenv.readthedocs.io) for the `Pipfile` [specification](https://github.com/pypa/pipfile)
* Note 2: you need to add both `Pipfile` and `Pipfile.lock` to your repository, otherwise you will not be able to restore the same environment
* Note 3: if you are currently using `requirements.txt` and want to migrate to `Pipfile`, here's an [handy guide](https://pipenv.readthedocs.io/en/latest/basics/#importing-from-requirements-txt) on how to do it

In the [template](https://github.com/gabrieleangeletti/python-package-template), both `pyenv` and `pipenv` can be installed through the `./setup.sh` script provided. It only supports Linux and MacOS (some packages need to be installed manually on Linux).

### Managing code - my favourite tools

Here's a list, in no specific order, of the code quality tools I always use in my Python projects.

#### Formatting - Black

According to [this book](https://www.amazon.co.uk/Power-Habit-Why-What-Change/dp/1847946240) I have recently read, willpower is a limited resource. It is like a muscle, you can't just stay focused for an entire day and expect the same level of productivity all along
. That's why when programming, I want to use my time thinking on the important stuff, not on indentation, brackets, and so on. Everything that can be automated *must* be automated. I can see at least two major benefits of code formatting:

* You cede control over formatting rules to the tool, which means you stop thinking about it
* Since everyone is onboard, you stop discussing with your team whether the perfect line lenght should be 42, 79 or 110 (or at least you have just one big discussion at the beginning)

[Black](https://github.com/psf/black) refers to itself as "the uncompromising Python code formatter", and it is my favourite formatting tool. It is super simple to use, just run:

```
black {source directory}
```

Black has a lot of configurable options. The only one I use is a line length of 110. If you check the full [project template](https://github.com/gabrieleangeletti/python-package-template), I have included a handy `./format_code.sh` script that will format your code in a single command.

#### Linting - Flake8

Linting is a rather basic code quality check that helps prevent simple bugs in your code. Things like typos, bad formatting, unused variables and so on. To me linting is super useful because:

* You don't have to check for minor details, hence you save time
* Other developers don't have to check for minor details, hence they save time

I use `flake8` for linting. One feature I particularly like is the ability to ignore specific warnings and errors. For instance, I use a line length of 110 which is against the [PEP8](https://www.python.org/dev/peps/pep-0008/) style guide (79 is recommended). By turning off the corresponding error `E501` I can safely use `flake8` with any desired line length.

In the [project template](https://github.com/gabrieleangeletti/python-package-template), you can run `flake8` against your package with `./test.sh lint`.

#### Type checking - Mypy

This is my favourite by far. This tool brings static type checking to the python world. I've never written a single line of untyped python since I've discovered `mypy`. I'm not gonna go into the details of static type checking, I'll just show you a simple example stolen from [mypy's website](http://mypy-lang.org/):

Standard python:

```
def fibonacci(n):
    a, b = 0, 1
    while a < n:
        yield a
        a, b = b, a+b
```

Typed python:

```
def fibonacci(n: int) -> Iterator[int]:
    a, b = 0, 1
    while a < n:
        yield a
        a, b = b, a+b
```

This is super useful because:

* I'm much more likely to understand what a function does by looking at its signature
* I can spot lots of errors before even running the code
* I can check whether I'm correctly using a third-party library

In the [project template](https://github.com/gabrieleangeletti/python-package-template), you can run `mypy` against your package with `./test.sh type_check`.

#### Testing - Pytest

[Pytest](https://docs.pytest.org/en/latest/) is the best testing framework for python. It gives you detailed info on why your tests are failing, can auto-discover your tests based on their name, has an amazing support for [fixtures](https://docs.pytest.org/en/latest/fixture.html#fixture), and a lot of useful plugins. Writing tests is super easy with `pytest`. Consider the following module `my_module.py`:

```
def my_func(x: int) -> int:
    return x ** 2
```

To test this function, we create a module named `my_module_test.py`:

```
from . import my_module


def test_my_func():
    expected = 9
    actual = my_module.my_func(3)
    assert actual == expected
```

The main features I use from `pytest`, in random order, are:

* `pytest-cov`: plugin that generates test coverage reports for your code, in a variety of formats
* `pytest-mock`: plugin that adds a fixture for [monkey-patching](https://stackoverflow.com/questions/5626193/what-is-monkey-patching). Usage:

```
def test_my_func(mocker):
    mocker.patch(...)
```

* `pytest-xdist`: run unit-tests in parallel. Especially useful for large codebases
* pytest's marking feature. You can label tests by using a decorator:

```
import pytest


@pytest.mark.integration
def test_my_integration_test():
    ...
```

Then you can run only the tests labeled as `integration`.

In the [project template](https://github.com/gabrieleangeletti/python-package-template), you can run `pytest` against your package with `./test.sh unit_tests`.


#### Others

Other dev. tools that I use in my projects are:

* `isort`: automatically sorts imports and separates them into sections: internal, first-party, third-party etc. Again, I'm all about automation, and this tool removes another thing from my mind
* `vulture` tool to check for dead code, like unused functions, unused constants etc. It's nice to keep your house clean, especially if you know about the [broken windows theory](https://en.wikipedia.org/wiki/Broken_windows_theory)

Please let me know your opinion in the comments below. The full code can be found [here](https://github.com/gabrieleangeletti/python-package-template) (instructions are in the readme).
