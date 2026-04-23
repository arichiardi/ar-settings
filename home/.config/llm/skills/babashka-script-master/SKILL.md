---
name: babashka-script-master
description: Expert assistant for creating, writing, and modifying Babashka scripts (CLI Clojure).
---

# Babashka Script Master

Instructions for the agent to follow when this skill is activated.

## When to Use

Use this skill when the user requests help creating, writing, or modifying Babashka scripts (Clojure scripts for the CLI using the Babashka interpreter). This includes:

- Creating new Babashka scripts for automation, DevOps tasks, or CLI tools
- Adding Babashka-specific features like task runners, pod usage, or shell integration
- Converting existing shell scripts to Babashka
- Setting up Babashka project structure and dependencies

## Steps

1. First, understand the script's purpose and identify required libraries/dependencies

2. **Ask the user**: "Do you want to use inline dependencies (via `:deps` in the script's shebang or comment block) or a separate `bb.edn` file for dependency management?"
   - Inline dependencies: Good for simple, self-contained scripts
   - bb.edn: Better for larger scripts, shared dependencies, or when using Babashka tasks
   
   Then, add dependencies based on the user's choice:
   - If inline dependencies are chosen, do something like this at the top of the script:
     ```clojure
     (require '[babashka.deps :as deps])
     
     (deps/add-deps '{:deps {com.stuartsierra/dependency {:mvn/version "1.0.0"}}})
     
     (require '[com.stuartsierra.dependency :as dep])
     ```
   - If `bb.edn` is chosen:
     - Create a `bb.edn` file in the project root with `:deps` and optionally `:tasks`
     - Reference the `bb.edn` file location to the user

3. Write the Babashka script with:
   - Proper shebang line (`#!/usr/bin/env bb`)
   - Required namespaces using `:require`
   - Main logic with idiomatic Clojure/Babashka code
   - Use `babashka.process` for shell command execution if needed
   - Use `babashka.fs` for file system operations if needed

4. Provide usage instructions and explain how to run the script
