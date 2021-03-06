#!/usr/bin/env groovy

REPOSITORY = 'static'

node {
  // Deployed by Puppet's Govuk_jenkins::Pipeline manifest
  def govuk = load '/var/lib/jenkins/groovy_scripts/govuk_jenkinslib.groovy'

  properties([
    buildDiscarder(
      logRotator(
        numToKeepStr: '50')
      ),
    [$class: 'RebuildSettings', autoRebuild: false, rebuildDisabled: false],
    [$class: 'ThrottleJobProperty',
      categories: [],
      limitOneJobWithMatchingParams: true,
      maxConcurrentPerNode: 1,
      maxConcurrentTotal: 0,
      paramsToUseForLimit: REPOSITORY,
      throttleEnabled: true,
      throttleOption: 'category'],
    [$class: 'ParametersDefinitionProperty',
      parameterDefinitions: [
        [$class: 'BooleanParameterDefinition',
          name: 'IS_SCHEMA_TEST',
          defaultValue: false,
          description: 'Identifies whether this build is being triggered to test a change to the content schemas'],
        [$class: 'StringParameterDefinition',
          name: 'SCHEMA_BRANCH',
          defaultValue: 'deployed-to-production',
          description: 'The branch of govuk-content-schemas to test against']]],
  ])

  try {
    govuk.setEnvar('GOVUK_APP_DOMAIN', 'dev.gov.uk')
    govuk.initializeParameters([
      'IS_SCHEMA_TEST': 'false',
      'SCHEMA_BRANCH': 'deployed-to-production',
    ])

    if (!govuk.isAllowedBranchBuild(env.BRANCH_NAME)) {
      return
    }

    stage('Build') {
      checkout scm

      govuk.cleanupGit()
      govuk.mergeMasterBranch()

      govuk.bundleApp()

      govuk.contentSchemaDependency(env.SCHEMA_BRANCH)
    }

    stage('Lint') {
      govuk.rubyLinter()
      govuk.sassLinter('app/assets/stylesheets/govuk-component')
    }

    stage('Test') {
      govuk.setEnvar('RAILS_ENV', 'test')

      govuk.runTests('test')
      govuk.runTests('spec:javascript')
    }

    stage('Validate assets') {
      govuk.setEnvar('RAILS_ENV', 'production')
      govuk.runRakeTask('assets:precompile')
    }

    stage('Deploy') {
      // pushTag and deployIntegration are no-ops unless on master branch
      govuk.pushTag(REPOSITORY, env.BRANCH_NAME, 'release_' + env.BUILD_NUMBER)
      govuk.deployIntegration(REPOSITORY, env.BRANCH_NAME, 'release', 'deploy')
    }

  } catch (e) {
    currentBuild.result = 'FAILED'
    step([$class: 'Mailer',
          notifyEveryUnstableBuild: true,
          recipients: 'govuk-ci-notifications@digital.cabinet-office.gov.uk',
          sendToIndividuals: true])
    throw e
  }
}
