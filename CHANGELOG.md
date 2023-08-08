<!-- markdownlint-disable MD024 -->
# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) and the format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), with some variations:

- `Added` for new features.
- `Changed` for changes in existing functionality.
- `Deprecated` for once-stable features removed in upcoming releases.
- `Removed` for deprecated features removed in this release.
- `Fixed` for any bug fixes.
- `Security` to invite users to upgrade in case of vulnerabilities.
- `Breaking` to indicate that it's a breaking change (meant to be used alongside another label).

## [Unreleased]

- `ui` service ARM image version.
- `ui` service with URL target environment variables for workspace URLs.
- Deploy command options to deploy the workspace without the `worker` and/or `ui` services.
- Automatically render links for the services in `wspace-ui` front-end according to one of three status of the service: *Unreachable*, *Error* or *Up & Running*.
- Functionality to setup a single service database.

## [1.5.0] - 2023-07-31

- [*Added*] A `wspace-config.json` file was added to centralize the workspace configuration; any integration can be directly set up in this file, and the workspace will adjust everything accordingly.

## [1.4.0] - 2023-07-04

- [*Changed*] The Worker token now have permissions in all tables of all services.

## [1.3.0] - 2023-05-04

- [*Changed*] The database container now exposes its port to allow external connections (allows **Valiot-App Template** to use the database).

## [1.2.1] - 2023-04-18

- [*Changed*] All token expiration changed from 30 days to 3,000,000 days.
- [*Changed*] `wspace-ui` service now display a copy-paste ready graphql header.
- [*Fixed*] Docker Desktop 4.18 update invalid project name error.
- [*Fixed*] Valiot App `FLAME_ON` and `POD_ID` enviroment variable errors.
- [*Fixed*] Changing `wspace-ui` port error.
- [*Fixed*] Better code structure for readme functions.
- [*Fixed*] set-version command compatibility for macOS terminal.
- [*Removed*] Docker scan suggetion removed for macOS terminal.

## [1.2.0] - 2023-04-13

- [*Fixed*] Docker images compatibility issue, now accepts native release images and distilerry release images.
- [*Changed*] `alerts` service updated to **alerts:5.0.0**.
- [*Changed*] `auth` service updated to **valiot-auth:3.3.0**.
- [*Changed*] `eliot` service updated to **eliot:8.1.0**.
- [*Changed*] `jobs` service updated to **jobs:6.0.0**.
- [*Changed*] `notifications` service updated to **notifications:5.0.0**.
- [*Changed*] `schedule-logic` service updated to **schedule-logic:4.0.0**.

## [1.1.1] - 2023-02-23

- [*Fixed*] Incorrect version on badge README.md file.

## [1.1.0] - 2023-02-21

- [*Added*] Default super-admin user creation in setup process.
- [*Added*] Setup generated resourses are shown in json format in `wspace-ui` front-end.
- [*Added*] Maintenance command to set the Composed Workspace version.
- [*Changed*] Setup process steps rearranged for optimal setup time and containers use.
- [*Changed*] `worker` service updated to **vcos-test-worker:e0045fc** which has an ARM image version.
- [*Changed*] `user` service updated to **valiot-user:4.3.0**.
- [*Changed*] `schedule-logic` service updated to **schedule-logic:3.3.0**.

## [1.0.0] - 2023-01-31

- [*Added*] Authentication command (*Docker* login to *Github*).
- [*Added*] Initialization command, all-in-one command for first time deployment.
- [*Added*] Download images and build containers command.
- [*Added*] Workspace database environment setup command, tokens, permissions and workers creation.
- [*Added*] Options for deploy command that gives multiple or single service console log outputs.
- [*Added*] Workspace deploy command.
- [*Added*] Independent services deploy command that allows to input custom container initialization commands.
- [*Added*] Stopping all or specific service command.
- [*Added*] Purge *Docker* command.
- [*Added*] Script usage CLI page. Full and reduced version.
- [*Added*] User interface for workspace services menu and usage guideline.
- [*Added*] pgAdmin service for workspace databases interaction.
- [*Added*] `valiot-app` development workspace: Build, deploy and stop commands.
- [*Added*] `valiot-app` test database setup command.
- [*Added*] `valiot-app` run automated tests command.
- [*Added*] `valiot-app` command to deploy the application in `dev` environment.
- [*Added*] `valiot-app` command to deploy the application in `dev` environment within an IEx terminal.
- [*Added*] `valiot-app` command to generate a test coverage report.
- [*Added*] `valiot-app` command to deploy the application in `prod` environment.
- [*Added*] `valiot-app` command to deploy the application that allows to input custom container initialization commands.
- [*Added*] Core engine built with *Docker Compose*.
