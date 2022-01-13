@Library('shared-library@dev/expandChangeLog') _

/**
 * How to add new stages?
 *
 * Use case: add a new integration test group
 * ------------------------------------------
 * Go to INTEGRATION_GROUPS map and configure your new group. The name of the group needs to match the @group
 * annotation in your PHPUnit test(s), so e.g. group calendar "calendar" will look for tests with the annotation
 * "@group integration-calendar".
 *
 * Use case: add a new acceptance test group
 * -----------------------------------------
 * Go to the ACCEPTANCE_GROUPS list and add the new group. The name of the group must match the tag name, so e.g. group
 * "external" will look for tests tagged as "@external".
 *
 * Use case: add a new stage
 * -------------------------
 * Let look into adding a new stage on a step-by-step basis
 *
 * Pick a good name for the stage that makes sense when a developer reads it:
 *     stage(<name>) {
 *
 * Next you need to select where the step should be run, in 90% of the cases that will be 'integration'
 *     agent { label 'integration' }
 * Nodes tagged with 'integration' are set up in a way that only a single step will run on a node, so you don’t have to
 * worry about isolation terribly much.
 *
 * Next we define the steps section, which is the actual build steps
 *     steps {
 *
 * If we want our step to appear standalone in the Github build status, we wrap all of our commands in a "notifyGithub"
 * block:
 * notifyGithub {
 *     checkoutRepository 'abc'
 *     antJob 'build-something'
 * }
 *
 * The way our pipeline works is we don’t start with an empty work directory. So we need to get a source tree now.
 * We have typically two scenarios here: either we just need a single repository or we need multiple repositories
 * side-by-side in different sub-directories.
 *
 * Checkout the relevant revision of the in repository into the current working directory:
 *     checkoutRepository 'abc'
 *
 * Or: checkout a few repositories into sub-directories
 *     checkoutRepositoryIntoSubdirectory 'in-solr', 'in-oms'
 * This will make the relevant revision of the in-solr repository available in a directory called "in-solr" and the
 * relevant revision of in-oms available in "in-oms" (both relative to the current working directory).
 *
 * Now that we have one source tree or more available, we can focus on our actual build steps. We typically either
 * execute ant, a shell script or yarn. Let‘s start with ant and use our custom "antJob" abstraction:
 * antJob 'my-ant-target'
 *
 * If we want to execute a shell script, we use our custom abstraction "command":
 * command 'echo "hello from shell"'
 *
 * For yarn we are opinionated in so far, that we always manage the node version with nvm, the node version manager.
 * This means we expect a repository to come with an ".nvmrc". Start opening a "withNvm" block and inside the block
 * you’ll magically have access to "nvmYarn", "nvmNpm" and "nvmNode" commands
 * withNvm {
 *     nvmYarn 'install'
 *     nvmNode 'path/to/foo.js'
 *     nvmNpm '--version'
 *     nvmYarn 'my-build-command'
 * }
 *
 * Once the actual build has finished, we come to the post build phase. This is where we clean up, publish reports etc.
 * post {
 *     success {
 *         …
 *     }
 *     unstable {
 *         …
 *     }
 *     always {
 *         …
 *     }
 *     cleanup {
 *         …
 *     }
 * }
 *
 * If we want to upload file into Nexus - Use the following method:
 * inNexusUpload("To which repository inside nexus", "Location inside the repository", "What is the current file location")
 * Here "Location inside the repository" = absolute path of the object inside the nexus repository
 * Ex: inNexusUpload(repository, remoteLocation, localFile)
 *
 * If we want to download a file from nexus - Use the following method:
 * inNexusDownload("From which nexus repository", "Name of the file to be downloaded along with the sub location", "Name of the file to be downloaded As")
 *
 * Ex: inNexusDownload(repository, remoteFile, localFile)
 *
 * Let’s say we want to publish reports. These are typically JUnit compatible XML files for which we use the "xunit"
 * function, checkstyle or PMD (project mess detector) compatible XML files for which we use the "recordIssues" function
 * provided by the warnings-ng plugin.
 *
 * This is how it looks for xunit test results provided by PHPUnit:
 * post {
 *     always {
 *          xunit thresholds: xunitThresholds(), tools: [PHPUnit(deleteOutputFiles: true, failIfNotNew: true, pattern: 'path/to/junit.xml', skipNoTestFiles: false, stopProcessingIfError: true)]
 *     }
 * }
 *
 * Use the snippet generator available at https://institution.org.org/job/in-community-pipeline/pipeline-syntax/ to
 * generate the snippet for your specific tool.
 *
 *
 * Let’s look at how we publish eslint warnings with warnings-ng:
 *
 * post {
 *     always {
 *         recordIssues enabledForFailure: true, publishAllIssues: true, qualityGates: [[threshold: 1, type: 'TOTAL_ERROR', unstable: false]], tools: [esLint(id: 'some-unique-id', name: 'headline for the report', pattern: 'path/to/report.xml')]
 *     }
 * }
 *
 * Last but not least we need to add a cleanup section to drop the workspace, so that branches don’t leave checkout
 * residue on each build node.
 *
 * post {
 *     …
 *     cleanup {
 *         cleanupWorkspace()
 *     }
 * }
 *
 * This is it, we have defined a new step.
 *
 *
 * To ease development of the pipeline it can be helpful to skip unecessary stages without removing the whole "stage
 * block" from the Jenkinsfile you can do it by adding the following block inside the stage block:
 *
 * when { expression { false } }
 */

/** Configuration */

REPOSITORY_REVISION_PROPERTY_MAP = [
        'in': 'GIT_APP_REVISION',
        'in-solr': 'GIT_SOLR_REVISION',
        'in-oms': 'GIT_OMS_REVISION',
        'in-cms': 'GIT_CMS_REVISION',
        'in-frontend': 'GIT_FRONTEND_REVISION',
]

REPOSITORY_PREVIOUS_REVISION_PROPERTY_MAP = [
        'in': 'GIT_APP_REVISION_PREVIOUS',
        'in-solr': 'GIT_SOLR_REVISION_PREVIOUS',
        'in-oms': 'GIT_OMS_REVISION_PREVIOUS',
        'in-cms': 'GIT_CMS_REVISION_PREVIOUS',
        'in-frontend': 'GIT_FRONTEND_REVISION_PREVIOUS',
]

REPOSITORY_BRANCH_PROPERTY_MAP = [
        'in': 'GIT_APP_BRANCH',
        'in-solr': 'GIT_SOLR_BRANCH',
        'in-oms': 'GIT_OMS_BRANCH',
        'in-cms': 'GIT_CMS_BRANCH',
        'in-frontend': 'GIT_FRONTEND_BRANCH',
]
DEPLOYMENT_PROPERTIES = [
        'NIGHTLY_BUILD',
        'MICROSTAGE',
        'MICROSTAGE_HOST',
        'HUMAN_STAGE_NAME',
        'DEPLOY',
        'NEXT',
        'BUILD_NUMBER',
]

PATHS = [
        in: [
                COMPOSER_ARCHIVE: 'build/vendor.tar.gz',
                COMPOSER_ARCHIVE_PHPCS: 'build/vendor-bin-phpcs.tar.gz',
                COMPOSER_ARCHIVE_PHP_CS_FIXER: 'build/vendor-bin-php-cs-fixer.tar.gz',
                COMPOSER_ARCHIVE_RECTOR: 'build/vendor-bin-rector.tar.gz',
                SYMFONY_FIXTURES: 'build/integration/fixtures.sql,',
                SYMFONY_CACHE_ARCHIVE: 'build/integration/cache.zip,',
                SYMFONY_DEPRECATION_LOGS: 'build/logs/deprecations*.log,var/cache/test/companyServiceContainerDeprecations*.log,',
                SYMFONY_LOGS: 'var/log/*.log,',
                PHPCS_CACHE: 'build/.phpcs.cache,',
                ESLINT_CACHE: '.eslintcache',
                NODE_MODULES_ARCHIVE: 'build/node_modules.tar.gz,',
                BEHAT_LOGS: 'build/behat-report/**/*.*',
                JQUERY_MIGRATION_LOG: 'build/logs/jquery-migration.log,',
                WEBPACK_CACHE_ARCHIVE: 'build/webpack-cache.zip,',
        ],
        frontend: [
                BUILD_ARCHIVE: 'frontend.zip,',
                NODE_MODULES_ARCHIVE: 'node_modules.tar.gz,',
                WEBPACK_ANALYSIS_REPORTS: 'frontend/.next/analysis/*/report.json,',
        ]
]

COMPOSER_ARTIFACT_ANT_TARGET_MAP = [
        'build/vendor.tar.gz':'composer-test-archive',
        'build/vendor-bin-phpcs.tar.gz':'composer-test-archive-phpcs',
        'build/vendor-bin-php-cs-fixer.tar.gz':'composer-test-archive-php-cs-fixer',
        'build/vendor-bin-rector.tar.gz':'composer-test-archive-rector'
]

INTEGRATION_GROUPS = [
        'calendar'               : [],
        'event-promo'            : [],
        'event-review'           : [],
        'groups'                 : [],
        'guestlist'              : [],
        'infra'                  : [
                extraTarget: 'ensure-composer-test-dependencies-php-cs-fixer ensure-composer-test-dependencies-phpcs ensure-composer-test-dependencies-rector',
                extraBuildDependencies: [PATHS.in.COMPOSER_ARCHIVE_PHP_CS_FIXER, PATHS.in.COMPOSER_ARCHIVE_PHPCS, PATHS.in.COMPOSER_ARCHIVE_RECTOR],
        ],
        'membership'             : [],
        'user'                   : [],
        'security'               : [],
        'api-spec'               : [],
        'functional'             : [solr: false, target: 'integration-functional'],
        'security-authentication': [],
        'forum'                  : [],
        'interruption'           : [],
        'seo'                    : [],
        'api-infra'              : [],
        'external-dependencies'  : [failureThreshold: null],
        'registration'           : [],
        'media'                  : [],
        'networking'             : [],
        'subscription'           : [],
        'zuora'                  : [],
        'non-isolated'           : [target: 'integration-non-isolated'],
]
ACCEPTANCE_GROUPS = [
        'activity',
        'adserver',
        'calendar',
        'common',
        'event-promotion',
        'event-review',
        'external',
        'forum',
        'group',
        'guestlist',
        'membership',
        'membership-2',
        'membership-creditcard',
        'membership-paypal',
        'membership-paywall',
        'membership-paywall-2',
        'networking',
        'profile',
        'registration',
        'registration-workflow',
        'security',
        'seo',
        'spa',
        'smoke',
        'subscription',
]

SPA_NODE_DEPENDENT_FILES = ['**/package.json', '**/yarn.lock', '**/patches/*'].join(',')

/** Global variables */

NEXT_BRANCH = null
GITHUB_NOTIFY_ORDINAL_NUMBER = 0

/** Pipeline declaration */

pipeline {
    agent none
    //triggers { cron('H H(2-4) * * *') }
    parameters {
        // We use "" (empty string) as a default value because null would be replaced with the value from a previous build.
        string(name: 'IN_BRANCH_NAME', description: 'Name of the branch to build across repositories', defaultValue: '', trim: true)
    }
    environment {
        NEXUS_CREDENTIALS = credentials('auth_value')
        GITHUB_CREDENTIALS_ID = 'github-company-rapidprofile'
        NEXUS_BASE_URL = "https://xxx.company.org"
    }
    options {
        ansiColor('xterm')
        timestamps()
        buildDiscarder logRotator(daysToKeepStr: '8', numToKeepStr: '25')
        skipDefaultCheckout()
    }
    stages {
        stage('Determine branches') {
            agent { label 'integration' }
            options { timeout(30) }
            steps {
                buildNodeInfo()
                script {
                    determineBuildParameter()
                    generateChangeLog()
                    notifyGithub { // Must happen *after* determining the branches here
                        githubNotifyPipelinePending()
                        setBuildDisplayName()
                    }
                }
            }
            post {
                cleanup {
                    cleanupWorkspace()
                }
                failure {
                    notifySlackOnFailures(currentBuild.currentResult, "#eng-ci")
                }
            }
        }
        stage('Auto-merge upgrades') {
            when { expression { env.GIT_APP_BRANCH.startsWith('dependabot/') || env.GIT_FRONTEND_BRANCH.startsWith('dependabot/') } }
            agent { label 'integration' }
            options { timeout(10) }
            steps {
                script {
                    if (env.GIT_APP_BRANCH.startsWith('dependabot/composer/')) {
                        dependabotRequestAutomerge('in', 'minor')
                    }
                    if (env.GIT_APP_BRANCH.startsWith('dependabot/npm_and_yarn/') && !isFrontendOnly()) {
                        dependabotRequestAutomerge('in', 'minor')
                    }
                    if (env.GIT_APP_BRANCH.startsWith('dependabot/npm_and_yarn/') && isFrontendOnly()) {
                        dependabotRequestAutomerge('in-frontend', 'minor')
                    }
                }
            }
            post {
                cleanup {
                    cleanupWorkspace()
                }
                failure {
                    notifySlackOnFailures(currentBuild.currentResult, "#guild-upgrades")
                }
            }
        }
        stage('Fast QA') {
            options { timeout(70) }
            parallel {
                stage('Git Invariant') {
                    when {
                        expression { isDeployBranch(getBranchName()) }
                        beforeAgent true
                    }
                    agent { label 'integration' }
                    steps {
                        script {
                            notifyGithub('fast-qa') {
                                buildNodeInfo()
                                ['in', 'in-frontend', 'in-solr', 'in-oms', 'in-cms', 'in-kit'].each { repository ->
                                    checkoutBranch("master", repository, repository)
                                }

                                dir('in-kit') {
                                    phpComposerInstall()
                                }

                                command "php in-kit/bin/in-kit git:invariant ."
                            }
                        }
                    }
                    post {
                        cleanup {
                            cleanupWorkspace()
                        }
                    }
                }
                stage('Classic unit tests') {
                    agent { label 'integration' }
                    when {
                        expression { !isFrontendOnly() }
                        beforeAgent true
                    }
                    steps {
                        notifyGithub('fast-qa') {
                            buildNodeInfo()
                            checkoutRepository 'abc'
                            installNodeModules()
                            antJob 'js-unit'
                        }
                    }
                    post {
                        always {
                            xunit thresholds: xunitThresholds(),
                                    tools: [GoogleTest(deleteOutputFiles: true, failIfNotNew: true, pattern: 'build/logs/**.xml', skipNoTestFiles: false, stopProcessingIfError: true)]
                        }
                        cleanup {
                            cleanupWorkspace()
                        }
                    }
                }
                stage('Classic lint') {
                    agent { label 'integration' }
                    when {
                        expression { !isFrontendOnly() }
                        beforeAgent true
                    }
                    steps {
                        notifyGithub('fast-qa') {
                            buildNodeInfo()
                            checkoutRepository 'abc'
                            installNodeModules()
                            restorePreviousBuildDependencies PATHS.in.ESLINT_CACHE

                            antJob 'eslint'
                        }
                    }
                    post {
                        always {
                            analyzeIssueReport(
                                    recordIssues(
                                            enabledForFailure: true,
                                            publishAllIssues: true,
                                            qualityGates: [[threshold: 1, type: 'TOTAL_ERROR', unstable: false]],
                                            tools: [esLint(
                                                    id: 'eslint-classic',
                                                    name: 'eslint classic',
                                                    pattern: 'build/logs/*lint.xml'
                                            )]
                                    )
                            )
                            archiveBuildDependencies PATHS.in.ESLINT_CACHE
                        }
                        cleanup {
                            cleanupWorkspace()
                        }
                    }
                }
                stage('Classic integration tests') {
                    agent { label 'integration' }
                    when {
                        expression { !isFrontendOnly() }
                        beforeAgent true
                    }
                    steps {
                        notifyGithub('fast-qa') {
                            buildNodeInfo()
                            checkoutRepository 'abc'
                            installNodeModules()
                            antJob 'js-integration'
                        }
                    }
                    post {
                        always {
                            xunit thresholds: xunitThresholds(),
                                tools: [GoogleTest(deleteOutputFiles: true, failIfNotNew: true, pattern: 'build/logs/*.xml', skipNoTestFiles: true, stopProcessingIfError: false)]
                        }
                        cleanup {
                            cleanupWorkspace()
                        }
                    }
                }
                stage('Backend lint') {
                    agent { label 'integration' }
                    when {
                        expression { !isFrontendOnly() }
                        beforeAgent true
                    }
                    steps {
                        notifyGithub('fast-qa') {
                            buildNodeInfo()
                            checkoutRepository 'abc'
                            installComposer(PATHS.in.COMPOSER_ARCHIVE)
                            installComposer(PATHS.in.COMPOSER_ARCHIVE_PHPCS)
                            restorePreviousBuildDependencies PATHS.in.PHPCS_CACHE
                            withTestCredentials {
                                antJob 'phpcs'
                            }
                            discoverGitReferenceBuild latestBuildIfNotFound: true,
                                maxCommits: 150,
                                skipUnknownCommits: true
                            analyzeIssueReport(
                                recordIssues(
                                    enabledForFailure: true,
                                    publishAllIssues: true,
                                    ignoreFailedBuilds: false,
                                    skipBlames: true,
                                    blameDisabled: true,
                                    qualityGates: [[threshold: 1, type: 'TOTAL_ERROR', unstable: false]],
                                    tools: [
                                        phpCodeSniffer(
                                            id: 'phpcs-community',
                                            name: 'phpcs community platform',
                                            pattern: 'build/logs/php-checkstyle.xml'
                                        )
                                    ]
                                )
                            )
                        }
                    }
                    post {
                        always {
                            archiveBuildDependencies PATHS.in.PHPCS_CACHE
                        }
                        cleanup {
                            cleanupWorkspace()
                        }
                    }
                }
                stage('Backend unit tests') {
                    agent { label 'integration' }
                    when {
                        expression { !isFrontendOnly() }
                        beforeAgent true
                    }
                    steps {
                        notifyGithub('fast-qa') {
                            buildNodeInfo()
                            checkoutRepository 'abc'
                            installComposer(PATHS.in.COMPOSER_ARCHIVE)
                            withTestCredentials {
                                antJob 'phpunit'
                            }
                        }
                    }
                    post {
                        always {
                            archiveLogs PATHS.in.SYMFONY_DEPRECATION_LOGS
                            xunit thresholds: xunitThresholds(),
                                tools: [PHPUnit(deleteOutputFiles: true, failIfNotNew: true, pattern: 'build/logs/junit-app.xml', skipNoTestFiles: false, stopProcessingIfError: true)]
                        }
                        cleanup {
                            cleanupWorkspace()
                        }
                    }
                }
                stage('OMS integration tests') {
                    /*when {
                        // We want to build this only on dev branches for in-oms or if we are building a deploy branch
                        expression { isDeployBranch(getBranchName()) || getBranchName() == GIT_OMS_BRANCH }
                        beforeAgent true
                    }*/
                    agent { label 'integration' }
                    steps {
                        notifyGithub('fast-qa') {
                            buildNodeInfo()
                            omsPhpunit()
                        }
                    }
                    post {
                        always {
                            xunit([PHPUnit(deleteOutputFiles: true, failIfNotNew: true, pattern: 'build/logs/junit-oms.xml', skipNoTestFiles: true, stopProcessingIfError: true)])
                        }
                        success {
                            echo "Upload the SHA of OMS"
                        }
                        cleanup {
                            cleanupWorkspace()
                        }
                    }
                }
                stage('Backend symfony cache') {
                    agent { label 'integration' }
                    when {
                        expression { !isFrontendOnly() }
                        beforeAgent true
                    }
                    steps {
                        notifyGithub('fast-qa') {
                            buildNodeInfo()
                            checkoutRepository 'abc'
                            installComposer(PATHS.in.COMPOSER_ARCHIVE)
                            withTestCredentials {
                                antJob 'symfony-cache'
                            }
                        }
                        dir('var/cache/test') {
                            command "mv companyServiceContainerDeprecations.log companyServiceContainerDeprecations-sf-cache.log"
                        }
                    }
                    post {
                        always {
                            archiveBuildDependencies PATHS.in.SYMFONY_CACHE_ARCHIVE
                            archiveBuildDependencies PATHS.in.SYMFONY_DEPRECATION_LOGS
                        }
                        cleanup {
                            cleanupWorkspace()
                        }
                    }
                }
                stage('Backend symfony lint') {
                    agent { label 'integration' }
                    when {
                        expression { !isFrontendOnly() }
                        beforeAgent true
                    }
                    steps {
                        notifyGithub('fast-qa') {
                            buildNodeInfo()
                            checkoutRepository 'abc'
                            installComposer(PATHS.in.COMPOSER_ARCHIVE)
                            withTestCredentials {
                                antJob 'symfony-lint'
                            }
                        }
                    }
                    post {
                        cleanup {
                            cleanupWorkspace()
                        }
                    }
                }
                stage('DS lint') {
                    agent { label 'integration' }
                    steps {
                        notifyGithub('fast-qa') {
                            buildNodeInfo()
                            checkoutRepository 'pqr'
                            uiLint()
                        }
                    }
                    post {
                        always {
                            analyzeIssueReport(
                                recordIssues(
                                    enabledForFailure: true,
                                    publishAllIssues: true,
                                    qualityGates: [[threshold: 1, type: 'TOTAL_ERROR', unstable: false]],
                                    tools: [esLint(
                                        id: 'eslint-ds',
                                        name: 'eslint DS',
                                        pattern: 'ds/build/*.xml'
                                    )]
                                )
                            )
                        }
                        cleanup {
                            cleanupWorkspace()
                        }
                    }
                }
                stage('SPA lint') {
                    agent { label 'integration' }
                    steps {
                        notifyGithub('fast-qa') {
                            buildNodeInfo()
                            checkoutRepository 'pqr'
                            spaLint()
                        }
                    }
                    post {
                        always {
                            analyzeIssueReport(
                                recordIssues(
                                    enabledForFailure: true,
                                    publishAllIssues: true,
                                    qualityGates: [[threshold: 1, type: 'TOTAL_ERROR', unstable: false]],
                                    tools: [esLint(
                                        id: 'eslint-spa',
                                        name: 'eslint SPA',
                                        pattern: 'frontend/build/*.xml'
                                    )]
                                )
                            )
                        }
                        cleanup {
                            cleanupWorkspace()
                        }
                    }
                }
                stage('SPA unit test') {
                    agent { label 'integration' }
                    steps {
                        notifyGithub('fast-qa') {
                            buildNodeInfo()
                            checkoutRepository 'pqr'
                            spaUnitTest()
                        }
                    }
                    post {
                        always {
                            xunit thresholds: xunitThresholds(),
                                tools: [GoogleTest(deleteOutputFiles: true, failIfNotNew: true, pattern: 'frontend/build/*-junit.xml', skipNoTestFiles: false, stopProcessingIfError: true)]
                        }
                        cleanup {
                            cleanupWorkspace()
                        }
                    }
                }
                stage('Service worker lint') {
                    agent { label 'integration' }
                    steps {
                        notifyGithub('fast-qa') {
                            buildNodeInfo()
                            checkoutRepository 'pqr'
                            installSpaNodeModules()
                            withNvm {
                                nvmYarn 'unarchive:node-modules'
                                nvmYarn '--cwd service-worker ci:lint'
                            }
                        }
                    }
                    post {
                        always {
                            analyzeIssueReport(
                                recordIssues(
                                    enabledForFailure: true,
                                    publishAllIssues: true,
                                    qualityGates: [[threshold: 1, type: 'TOTAL_ERROR', unstable: false]],
                                    tools: [esLint(
                                        id: 'eslint-service-worker',
                                        name: 'eslint service worker',
                                        pattern: 'service-worker/build/*.xml'
                                    )]
                                )
                            )
                        }
                        cleanup {
                            cleanupWorkspace()
                        }
                    }
                }
                stage('Service worker unit test') {
                    agent { label 'integration' }
                    steps {
                        notifyGithub('fast-qa') {
                            buildNodeInfo()
                            checkoutRepository 'pqr'
                            installSpaNodeModules()
                            withNvm {
                                nvmYarn 'unarchive:node-modules'
                                nvmYarn '--cwd service-worker test'
                            }
                        }
                    }
                    post {
                        always {
                            xunit thresholds: xunitThresholds(),
                                tools: [GoogleTest(deleteOutputFiles: true, failIfNotNew: true, pattern: 'service-worker/build/*-junit.xml', skipNoTestFiles: false, stopProcessingIfError: true)]
                        }
                        success {
                            cobertura enableNewApi: true, coberturaReportFile: 'service-worker/build/coverage/cobertura-coverage.xml'
                        }
                        cleanup {
                            cleanupWorkspace()
                        }
                    }
                }
            }
            post {
                failure {
                    notifySlackOnFailures(currentBuild.currentResult, "#pxt_drhaus")
                }
            }
        }
        stage('Prepare services deploy') {
            agent { label 'integration' }
            when {
                environment name: 'DEPLOY', value: 'true'
                beforeAgent true
            }
            steps {
                deploymentMilestone('services', 10)
            }
            post {
                failure {
                    notifySlackOnFailures(currentBuild.currentResult, "#eng-infrastructure")
                    notifySlackOnFailures(currentBuild.currentResult, "#pxt-pokemon")
                }
            }
        }
        stage('Deploy services') {
            options { timeout(30) }
            parallel {
                stage('CMS deploy stage') {
                    when {
                        environment name: 'DEPLOY', value: 'true'
                        beforeAgent true
                    }
                    agent { label 'master' }
                    steps {
                        deployService('cms', 'in-cms', 'env', 'cms_env')
                    }
                    post {
                        always {
                            notifySlack currentBuild.currentResult
                        }
                        cleanup {
                            cleanupWorkspace()
                        }
                    }
                }
                stage('OMS deploy stage') {
                    when {
                        environment name: 'DEPLOY', value: 'true'
                        beforeAgent true
                    }
                    agent { label 'master' }
                    steps {
                        deployService('oms', 'in-oms', 'env', 'env_file')
                    }
                    post {
                        always {
                            notifySlack currentBuild.currentResult
                        }
                        cleanup {
                            cleanupWorkspace()
                        }
                    }
                }
                stage('Solr deploy stage') {
                    when {
                        environment name: 'DEPLOY', value: 'true'
                        beforeAgent true
                    }
                    agent { label 'master' }
                    steps {
                        deployService('solr', 'in-solr', 'properties', 'properties_file')
                    }
                    post {
                        always {
                            notifySlack currentBuild.currentResult
                        }
                        cleanup {
                            cleanupWorkspace()
                        }
                    }
                }
            }
            post {
                failure {
                    notifySlackOnFailures(currentBuild.currentResult, "#eng-infrastructure")
                    notifySlackOnFailures(currentBuild.currentResult, "#pxt-pokemon")
                }
            }
        }
        stage('Setup backend integration tests') {
            agent { label 'integration' }
            options {
                timeout(30)
            }
            when {
                expression { !isFrontendOnly() }
                beforeAgent true
            }
            steps {
                notifyGithub('integration-tests', 'setup') {
                    buildNodeInfo()
                    checkoutRepositoryIntoSubdirectory 'in', 'in-solr'
                    restoreCurrentBuildDependencies PATHS.in.SYMFONY_CACHE_ARCHIVE, 'in'
                    installComposer(PATHS.in.COMPOSER_ARCHIVE, 'in')
                    withTestCredentials {
                        command 'cp $company_SOLR_PROPERTIES_FILE in-solr/solr.properties'
                        antJob 'install-integration', 'in-solr/build.xml', sudo: true
                        antJob 'integration-setup', 'in/build.xml'
                    }
                }
            }
            post {
                success {
                    archiveBuildDependencies PATHS.in.SYMFONY_FIXTURES, 'in'
                }
                unstable {
                    archiveBuildDependencies PATHS.in.SYMFONY_FIXTURES, 'in'
                }
                failure {
                    notifySlackOnFailures(currentBuild.currentResult, "#pxt-pokemon")
                }
                cleanup {
                    cleanupWorkspace()
                }
            }
        }
        stage('Backend integration Tests') {
            agent { label 'integration' }
            options {
                timeout(30)
            }
            when {
                expression { !isFrontendOnly() }
                beforeAgent true
            }
            steps {
                script {
                    notifyGithub('integration-tests') {
                        parallel(integrationTestStages(INTEGRATION_GROUPS))
                    }
                }
            }
            post {
                failure {
                    notifySlackOnFailures(currentBuild.currentResult, "#pxt-pokemon")
                }
            }
        }
        stage('Deploy build') {
            options { timeout(30) }
            parallel {
                stage('Deploy stage timezone DB') {
                    when {
                        environment name: 'DEPLOY', value: 'true'
                        beforeAgent true
                    }
                    agent { label 'master' }
                    steps {
                        notifyGithub('deploy', 'timezone-db') {
                            notifySlack()
                            buildNodeInfo()
                            checkoutRepository 'abc'
                            /**
         * No milestone necessary to force deployments to be orderly because this step always
         * installs the latest version of the timezone. That means that an older pipeline cannot
         * override a newer pipeline’s deployment.
         */
                            lockDeployment('timezonedb') {
                                deployStageTimezoneDb()
                            }
                        }
                    }
                    post {
                        always {
                            notifySlack currentBuild.currentResult
                        }
                        cleanup {
                            cleanupWorkspace()
                        }
                    }
                }
                stage('Build SPA') {
                    when {
                        expression { env.DEPLOY == 'true' || isFrontendOnly() }
                        beforeAgent true
                    }
                    agent { label 'integration' }
                    steps {
                        notifyGithub('deploy', 'build-spa') {
                            buildNodeInfo()
                            checkoutRepository 'pqr'
                            buildSpa(env.MICROSTAGE == 'true' ? 'microstage' : 'stage')
                        }
                    }
                    post {
                        cleanup {
                            cleanupWorkspace()
                        }
                    }
                }
                stage('Report deprecations') {
                    when {
                        expression { env.DEPLOY == 'true' && !isFrontendOnly() }
                        beforeAgent true
                    }
                    agent { label 'integration' }
                    environment {
                        php = "php -dmemory_limit=4G"
                    }
                    steps {
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                            buildNodeInfo()
                            checkoutBranch 'master', 'in-kit'
                            restoreCurrentBuildLogs PATHS.in.SYMFONY_DEPRECATION_LOGS
                            phpComposerInstall()
                            command "${env.php} bin/in-kit ci:deprecations:merge deprecations.json ${PATHS.in.SYMFONY_DEPRECATION_LOGS.split(',').join(' ')}"
                            command "${env.php} bin/in-kit ci:deprecations:pmd-report deprecations.json pmd.xml"
                        }
                    }
                    post {
                        always {
                            analyzeIssueReport(
                                recordIssues(
                                    enabledForFailure: true,
                                    publishAllIssues: true,
                                    tools: [pmdParser(
                                        id: 'pmd-deprecations-community',
                                        name: 'Backend deprecations community platform',
                                        pattern: 'pmd.xml'
                                    )]
                                )
                            )
                        }
                        cleanup {
                            cleanupWorkspace()
                        }
                    }
                }
                stage('DB schema production compatibility') {
                    when {
                        expression { !(env.GIT_APP_BRANCH.startsWith('dependabot/') || isFrontendOnly()) }
                        beforeAgent true
                    }
                    agent { label 'integration' }
                    steps {
                        notifyGithub('compatibility', 'db-schema') {
                            checkoutRepositoryIntoSubdirectory 'in', 'in-solr'
                            restoreCurrentBuildDependencies PATHS.in.SYMFONY_CACHE_ARCHIVE + PATHS.in.SYMFONY_FIXTURES, 'in'
                            withTestCredentials {
                                antJob 'integration-setup-db-fixtures', 'in/build.xml'
                            }
                        }
                    }
                    post {
                        cleanup {
                            cleanupWorkspace()
                        }
                    }
                }
            }
            post {
                failure {
                    notifySlackOnFailures(currentBuild.currentResult, "#pxt_drhaus")
                }
            }
        }
        stage('Deploy app to stage') {
            when {
                environment name: 'DEPLOY', value: 'true'
                beforeAgent true
            }
            agent { label 'master' }
            options {
                timeout(time: 2, unit: 'HOURS')
            }
            steps {
                notifyGithub('deploy', 'stage') {
                    notifySlack()
                    buildNodeInfo()
                    checkoutRepository 'abc'
                    restorePreviousBuildDependencies PATHS.in.WEBPACK_CACHE_ARCHIVE
                    installComposer(PATHS.in.COMPOSER_ARCHIVE)
                    installNodeModules()
                    restoreCurrentBuildDependencies PATHS.frontend.BUILD_ARCHIVE, 'build'
                    sshagent(['github-company-rapidprofile']) {
                        withStageCredentials {
                            deploymentMilestone('app', 30)
                            lockDeployment('app') {
                                deployAppStage()
                            }
                        }
                    }
                }
            }
            post {
                always {
                    archiveBuildDependencies PATHS.in.WEBPACK_CACHE_ARCHIVE
                    notifySlack currentBuild.currentResult
                }
                failure {
                    notifySlackOnFailures(currentBuild.currentResult, "#pxt_drhaus")
                }
                cleanup {
                    cleanupWorkspace()
                }
            }
        }
        stage('Post-deploy backend integration tests') {
            when {
                environment name: 'DEPLOY', value: 'true'
                beforeAgent true
            }
            agent { label 'integration' }
            options {
                timeout(30)
            }
            steps {
                notifyGithub('integration-tests', 'post') {
                    buildNodeInfo()
                    checkoutRepository 'abc'
                    installComposer(PATHS.in.COMPOSER_ARCHIVE)
                    withTestCredentials {
                        antJob 'integration-post'
                    }
                }
            }
            post {
                always {
                    xunit thresholds: xunitThresholds(),
                        tools: [PHPUnit(deleteOutputFiles: true, failIfNotNew: true, pattern: 'build/logs/junit-integration-post.xml', skipNoTestFiles: false, stopProcessingIfError: true)]
                }
                failure {
                    notifySlackOnFailures(currentBuild.currentResult, "#pxt-pokemon")
                }
                cleanup {
                    cleanupWorkspace()
                }
            }
        }
        stage('Setup acceptance tests') {
            when {
                environment name: 'DEPLOY', value: 'true'
                beforeAgent true
            }
            agent { label 'acceptance' }
            options {
                timeout(time: 1, unit: 'HOURS')
            }
            steps {
                notifyGithub('acceptance-tests', 'setup') {
                    buildNodeInfo()
                    checkoutRepository 'abc'
                    installComposer(PATHS.in.COMPOSER_ARCHIVE)
                    withAcceptanceCredentials {
                        antJob 'acceptance-setup'
                    }
                }
            }
            post {
                always {
                    setBuildDisplayName()
                }
                cleanup {
                    cleanupWorkspace()
                }
                failure {
                    notifySlackOnFailures(currentBuild.currentResult, "#pxt-pokemon")
                }
            }
        }
        stage('Acceptance tests') {
            when {
                environment name: 'DEPLOY', value: 'true'
                beforeAgent true
            }
            options {
                timeout(time: 1, unit: 'HOURS')
            }
            agent { label 'acceptance' }
            steps {
                script {
                    notifyGithub('acceptance-tests') {
                        parallel(createAcceptanceTestStages(ACCEPTANCE_GROUPS) + createLighthouseStages())
                    }
                }
            }
        }
    }
    post {
        always {
            node('integration') {
                githubNotifyPipelineCompleted()
            }
        }
        failure {
            dependabotCancelAutomerge()
        }
    }
}

/** Build steps */

void determineBuildParameter() {
    // Use the branch name of the current commit as a fallback if not triggered via external job
    env.IN_BRANCH_NAME = env.IN_BRANCH_NAME ?: env.BRANCH_NAME

    def branchCandidates = [getBranchName()]
    if (isHotfixBranch(getBranchName())) {
        branchCandidates << 'master'
    } else if (isDevBranch(getBranchName()) || isDependabotBranch(getBranchName())) {
        branchCandidates << getNextBranch()
    }

    //We do a checkout of all the repositories where this branch is existing(We need to do a git log on these directories to list the changes)
    sshagent(['github-company-rapidprofile']) {
        REPOSITORY_BRANCH_PROPERTY_MAP.each { repository, branchProperty ->
            if (inDoesThisBranchExists(repository, env.BRANCH_NAME)) {
                checkoutBranch(env.BRANCH_NAME, repository, repository, true)
            } else {
                echo "Branch is not present in repository: \"${repository}\""
            }
        }
    }

    dir('in') {
        sshagent(['github-company-rapidprofile']) {
            antJob 'build-parameters'
        }
        def props = readProperties file: 'ci.properties'
        getBuildProperties().each { property ->
            env[property] = props.get(property, env[property])
        }
    }

    def info = []
    info << String.format('IN_BRANCH_NAME parameter: "%s"', params.IN_BRANCH_NAME)
    info << String.format('BRANCH_NAME env (source of Jenkinsfile): "%s"', env.BRANCH_NAME)
    info << String.format('Branch candidates for determining build parameters: "%s"', branchCandidates.join('", "'))
    info << String.format('Target branch to build across repositories: "%s"', getBranchName())
    REPOSITORY_BRANCH_PROPERTY_MAP.inject(info) { list, repository, branchProperty ->
        list << String.format('Building "%s" "%s" ("%s")', repository, env[branchProperty], env[REPOSITORY_REVISION_PROPERTY_MAP[repository]].substring(0, 8))
    }
    if (env.DEPLOY == 'true') {
        info << String.format('Deploying to "%s"', env.HUMAN_STAGE_NAME)
    } else {
        info << 'Not deployed'
    }

    sshagent(['github-company-rapidprofile']) {
        String refTag = getTagName(env.BRANCH_NAME)
        env.REF = getRefOfTip("in", env.BRANCH_NAME)
        env.REF_CONTAINING_TAG = getTagRef("in", refTag)
        echo "ref is ${env.REF} and tag ref is ${env.REF_CONTAINING_TAG}"
    }
    info << String.format('Frontend only: "%s"', isFrontendOnly())

    currentBuild.description = info.join(' | ')
}

void generateChangeLog() {
    milestone(label: 'calculate-changeLog', ordinal: 5)
    lock("changelog-calculation-${env.BRANCH_NAME}") {
        //Logic for downloading previous build's ci.properties file to calculate the changelog
        try {
            String remoteFilePath = ""
            if (!inNexusExists("ci-properties-files", "${env.BRANCH_NAME}/ci.properties")) {
                if (isDeployBranch(env.BRANCH_NAME) || isDevBranch(env.BRANCH_NAME) || isDependabotBranch(env.BRANCH_NAME) && env.BRANCH_NAME != 'master') {
                    String deployBranch = inGetNextBranch()
                    remoteFilePath = "${deployBranch}/ci.properties"
                } else if (isHotfixBranch(env.BRANCH_NAME)) {
                    remoteFilePath = "master/ci.properties"
                } else {
                    echo "This branch doesn't satisfy the usual naming convention of branch creation, so changelog could not be calculated.\nPlease follow this while creating a branch: https://wiki.company.org/display/ENG/Git+Branching+Model"
                }
            } else {
                remoteFilePath = "${env.BRANCH_NAME}/ci.properties"
            }

            inNexusDownload("ci-properties-files", remoteFilePath, "ci-previous.properties")

            //We need different keys for a map so we add a string "PREVIOUS".
            def previousProps = readProperties file: 'ci-previous.properties'
            getBuildProperties().each { property ->
                env["${property}_PREVIOUS"] = previousProps.get(property, env[property])
            }

            //Calculate the changelog for the repositories where this branch is present.

            sshagent(['github-company-rapidprofile']) {
                echo "ChangeLog calculation starts now"
                REPOSITORY_BRANCH_PROPERTY_MAP.each { repository, branchProperty ->
                    if (inDoesThisBranchExists(repository, env.BRANCH_NAME)) {
                        println("${env[branchProperty]} exists in repository: ${repository}")
                        String currentSha = env[REPOSITORY_REVISION_PROPERTY_MAP[repository]]
                        String previousSha = env[REPOSITORY_PREVIOUS_REVISION_PROPERTY_MAP[repository]]
                        String changeLog = inChangeLog(repository, previousSha, currentSha)
                        if (!changeLog.isEmpty()) {
                            writeFile file: "${repository}-changeLog.txt", text: changeLog
                            archiveLogs("${repository}-changeLog.txt")
                        }
                    }
                }
            }
        } catch (e) {
            echo "Getting error because: ${e}"
        } finally {
            dir("in") {
                String remoteLocation = env.BRANCH_NAME + "/" + "ci.properties"
                inNexusUpload("ci-properties-files", remoteLocation, "ci.properties")
            }
        }
    }
}

void installComposer(String composerArchiveAsset, String checkoutLocation = "", String unarchiveLocation = "build") {
    def composerAntTarget = COMPOSER_ARTIFACT_ANT_TARGET_MAP[composerArchiveAsset]
    String composerDependentFiles = ['composer.json', 'composer.lock', 'patches/composer/*'].join(',')
    String composerNonDependentFiles = ['patches/composer/README.md'].join(',')
    dir(checkoutLocation) {
        withAssetArchive('composer-modules', composerArchiveAsset, composerDependentFiles, composerNonDependentFiles, unarchiveLocation) {
            antJob composerAntTarget
        }
    }
}

void installSpaNodeModules() {
    withAssetArchive('node-modules', '/node_modules.tar.gz', SPA_NODE_DEPENDENT_FILES, '') {
        withNvm {
            nvmYarn 'install'
            nvmYarn 'archive:node-modules'
        }
    }
}

void installNodeModules() {
    String nodeDependentFiles = ['package.json', 'yarn.lock', 'patches/npm/*'].join(',')
    String nodeNonDependentFiles = ['patches/npm/README.md'].join(',')
    withAssetArchive('node-modules', 'build/node_modules.tar.gz', nodeDependentFiles, nodeNonDependentFiles, 'build') {
        antJob 'node-modules-archive'
    }
}

void withAssetArchive(String repository, String archiveAsset, String dependencyFileGlob, String dependencyFileGlobExclude, String unarchiveFolder = "", Closure install) {
    String archiveFolder = archiveAsset.substring(0, archiveAsset.lastIndexOf('/'))
    String archiveName = archiveAsset.substring(archiveAsset.lastIndexOf('/') + 1)
    def files = findFiles(glob: dependencyFileGlob, excludes: dependencyFileGlobExclude)
    List<String> hashes = files.collect { file -> sha1(file: file.path) }
    writeCSV file: "${archiveName}.txt", records: hashes
    String suffix = sha1 file: "${archiveName}.txt"
    def (filename, extension) = archiveName.split("(?=\\.)",2)
    String archive = "${filename}-${suffix}${extension}"
    if (inNexusExists(repository, archive)) {
        dir(unarchiveFolder) {
            inNexusDownload(repository, archive, archiveName)
        }
        return
    }
    echo "The archive \"${archiveName}\" is not present in Nexus, so we do a re-check and if required build it."
    lock("asset-archive-${repository}-${archive}") {
        if (inNexusExists(repository, archive)) {
            dir(unarchiveFolder) {
                inNexusDownload(repository, archive, archiveName)
            }
        } else {
            install()
            dir(archiveFolder) {
                inNexusUpload(repository, archive, archiveName)
            }
        }
    }
}

String getTagRef(String repository, String refTag) {
    sshagent(['github-company-rapidprofile']) {
        Map<String, String> refs = sh(returnStdout: true, script: "git ls-remote --tags git@github.com:company/${repository}.git").trim().split("\n").collectEntries {
            line -> (revision, tag) = line.split("\t");
                [tag.replaceFirst('refs/tags/', ''), revision]
        }
        return refs.get(refTag)
    }
}

String getRefOfTip(String repository, String branchIn) {
    sshagent(['github-company-rapidprofile']) {
        Map<String, String> refs = sh(returnStdout: true, script: "git ls-remote --heads git@github.com:company/${repository}.git").trim().split("\n").collectEntries {
            line -> (revision, branch) = line.split("\t");
                [branch.replaceFirst('refs/heads/', ''), revision]
        }
        return refs.get(branchIn)
    }
}

void buildSpa(stage) {
    def wasBuild = false

    withAssetArchive('ci-internal-files', '/next-cache.tar.gz', SPA_NODE_DEPENDENT_FILES, '') {
        doBuildSpa(stage)
        wasBuild = true
    }

    if (!wasBuild) {
        doBuildSpa(stage)
    }
}

void doBuildSpa(stage) {
    withEnv(['NEXT_TELEMETRY_DISABLED=1', 'SCARF_ANALYTICS=false', "STAGE=${stage}"]) {
        installSpaNodeModules()
        withNvm {
            if (fileExists('next-cache.tar.gz')) {
                nvmYarn 'unarchive next-cache.tar.gz frontend/.next/cache'
            }

            nvmYarn 'unarchive:node-modules'
            nvmYarn 'build'
            nvmYarn 'ci:archive-build'
            nvmYarn 'archive next-cache.tar.gz frontend/.next/cache'
            archiveBuildDependencies PATHS.frontend.BUILD_ARCHIVE
            archiveLogs PATHS.frontend.WEBPACK_ANALYSIS_REPORTS
            publishSpaWebpackReport('server')
            publishSpaWebpackReport('client')
        }
    }
}

void spaUnitTest() {
    installSpaNodeModules()
    withNvm {
        nvmYarn 'unarchive:node-modules'
        nvmYarn '--cwd ds build:assets'
        nvmYarn '--cwd frontend ci:test'
    }
}

void uiLint() {
    installSpaNodeModules()
    withNvm {
        nvmYarn 'unarchive:node-modules'
        nvmYarn '--cwd ds ci:lint'
    }
}

void spaLint() {
    installSpaNodeModules()
    withNvm {
        nvmYarn 'unarchive:node-modules'
        nvmYarn '--cwd ds build:assets'
        nvmYarn '--cwd frontend ci:lint'
    }
}

void omsPhpunit() {
    // Checkout the repository and save the resulting metadata
    def scmVars = checkoutRepository 'xyz'
    println(scmVars)
    withCredentials([
            file(credentialsId: 'company-oms-test-env-file', variable: 'company_OMS_ENV_FILE_TEST'),
            file(credentialsId: 'company-oms-test-properties-file', variable: 'company_OMS_PROPERTIES_FILE_TEST')
    ]) {
        def isTimerBuild = isJobStartedByTimer()
        echo "The current commit on OMS Revision VARS: ${env.GIT_OMS_REVISION}"
    }
}

void deployStageTimezoneDb() {
    if (env.MICROSTAGE == 'true') {
        withEnv(['CAP_STAGE=app-microstage', 'APP_STAGE=microstage', "HOSTFILTER=${env.MICROSTAGE_HOST}"]) {
            command "cap -s domain=${env.MICROSTAGE_HOST} ${env.CAP_STAGE} deploy:php_timezonedb"
        }
    } else {
        withEnv(['CAP_STAGE=app-stage', 'APP_STAGE=stage']) {
            command "cap -s domain=${env.MICROSTAGE_HOST} ${env.CAP_STAGE} deploy:php_timezonedb"
        }
    }
}

void deployAppStage() {
    withEnv(env.MICROSTAGE == 'true' ? ["HOSTFILTER=${env.MICROSTAGE_HOST}"] : []) {
        antJob 'deploy'
    }
}

def integrationTestStages(groups) {
    groups.collectEntries{ group, config ->
        config = [solr: true, target: 'integration', failureThreshold: 0] + config
        [(group): {
            stage(group) {
                node('integration') {
                    try {
                        buildNodeInfo()
                        checkoutRepositoryIntoSubdirectory 'in'

                        restoreCurrentBuildDependencies PATHS.in.SYMFONY_FIXTURES + PATHS.in.SYMFONY_CACHE_ARCHIVE, 'in'
                        installComposer(PATHS.in.COMPOSER_ARCHIVE, 'in')

                        if(config.extraBuildDependencies) {
                            config.extraBuildDependencies.each { archiveAsset ->
                                installComposer(archiveAsset, 'in')
                            }
                        }

                        if (config.solr) {
                            checkoutRepositoryIntoSubdirectory 'in-solr'
                            withTestCredentials {
                                command 'cp $company_SOLR_PROPERTIES_FILE in-solr/solr.properties'
                                antJob 'install-integration', 'in-solr/build.xml', sudo: true
                            }
                        }

                        withTestCredentials {
                            if (config.extraTarget) {
                                antJob config.extraTarget, 'in/build.xml'
                            }
                            antJob config.target, 'in/build.xml', options: "-Dphpunit.integration.group=${group} -Dphpunit.integration.failonerror=false"
                        }

                        dir('in/var/log') {
                            command "mv test.log test_${group}.log"
                        }
                        dir('in/var/cache/test') {
                            command "! test -e companyServiceContainerDeprecations.log || mv companyServiceContainerDeprecations.log companyServiceContainerDeprecations-${group}.log"
                        }
                    } finally {
                        archiveLogs PATHS.in.SYMFONY_LOGS, 'in'
                        archiveLogs PATHS.in.SYMFONY_DEPRECATION_LOGS, 'in'

                        def testResult = xunit(thresholds: xunitThresholds(config.failureThreshold),
                                tools: [PHPUnit(deleteOutputFiles: true, failIfNotNew: true, pattern: 'in/build/logs/junit-*.xml', skipNoTestFiles: false, stopProcessingIfError: true)])

                        if (testResult.getSkipCount() > 0) {
                            unstable('Skipped tests exceed threshold')
                        }

                        if (testResult.getFailCount() > 0) {
                            if (config.failureThreshold != null && testResult.getFailCount() > config.failureThreshold) {
                                error('Failed tests exceed threshold')
                            } else {
                                unstable('Failed tests found')
                            }
                        }

                        cleanupWorkspace()
                    }
                }
            }
        }]
    }
}

def createAcceptanceTestStages(groups) {
    groups.collectEntries { group ->
        [(group): {
            stage(group) {
                node('acceptance') {
                    ws('shared-workspace/in-acceptance') {
                        try {
                            buildNodeInfo()
                            checkoutRepository 'abc'
                            installNodeModules()
                            installComposer(PATHS.in.COMPOSER_ARCHIVE)
                            withAcceptanceCredentials {
                                antJob 'acceptance-grouped', options: "-Dtag=${group}"
                            }
                        } finally {
                            archiveLogs PATHS.in.JQUERY_MIGRATION_LOG
                            archiveLogs PATHS.in.BEHAT_LOGS
                            def files = findFiles glob: 'build/behat-report/*/*'
                            if (files.length > 0) {
                                publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'build/behat-report/', reportFiles: '*-index.html', reportName: "Behat failures ${group}"])
                            }
                            def summary = xunit([Custom(customXSL: 'util/behat/junit.xsl', deleteOutputFiles: true, failIfNotNew: false, pattern: 'build/logs/behat/**/*.xml', skipNoTestFiles: true, stopProcessingIfError: false)])
                            notifySlackAcceptanceTests(summary, group)
                            cleanupWorkspace()
                        }
                    }
                }
            }
        }]
    }
}

def createLighthouseStages() {
    def stageName = 'lighthouse'

    [(stageName): {
        stage(stageName) {
            node('acceptance') {
                try {
                    buildNodeInfo()
                    checkoutRepository 'abc'
                    installNodeModules()
                    antJob 'lighthouse-regression'
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, includes: '**/*.html', keepAll: false, reportDir: './build/lighthouse/reports', reportFiles: '*.html', reportName: 'Lighthouse report'])
                } finally {
                    def summary = xunit(
                            [GoogleTest(
                                    deleteOutputFiles: true,
                                    failIfNotNew: true,
                                    pattern: 'build/lighthouse/logs/**.xml',
                                    skipNoTestFiles: false,
                                    stopProcessingIfError: false
                            )]
                    )
                    notifySlackAcceptanceTests(summary, stageName)
                    cleanupWorkspace()
                }
            }
        }
    }]
}

/** Library functions */

void cleanupWorkspace() {
    cleanWs()
}

def withNvm(fn) {
    fn.delegate.nvmDir =  'build/nvm'
    fn.delegate.nvmInstall = {
        if (fileExists("${nvmDir}/nvm.sh")) {
            return
        }
        command label: 'Setup nvm', """
export NVM_DIR=${nvmDir}
export PROFILE=/dev/null
mkdir -p \$NVM_DIR
curl --fail -o - https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
set +x
source \$NVM_DIR/nvm.sh --no-use
echo "Install"
nvm install || true
echo "Use"
nvm use --delete-prefix
set -x
"""
    }
    fn.delegate.nvmSource = {
        return "set +x; source ${nvmDir}/nvm.sh; set -x; "
    }
    fn.delegate.nvmNpm = { args ->
        nvmInstall()
        command "${nvmSource()} npm ${args}", label: "npm ${args}"
    }
    fn.delegate.nvmNode = { args ->
        nvmInstall()
        command "${nvmSource()} node ${args}", label: "node ${args}"
    }
    fn.delegate.nvmYarn = { args ->
        nvmInstallYarn()
        nvmNode "node_modules/.bin/yarn ${args}"
    }
    fn.delegate.nvmInstallYarn = {
        if (fileExists('node_modules/.bin/yarn')) {
            return
        }
        nvmNpm 'install yarn'
    }

    fn()
}

def checkoutRepository(String repository) {
    checkoutRevision(env[REPOSITORY_REVISION_PROPERTY_MAP[repository]], repository)
}

def checkoutRepositoryIntoSubdirectory(String ...repositories) {
    repositories.each { repository -> checkoutRevision(env[REPOSITORY_REVISION_PROPERTY_MAP[repository]], repository, repository) }
}

void checkoutBranch(String branchName, String repository, String targetDir = '', Boolean withChangelog = false) {
    checkoutBranch([branchName], repository, targetDir, withChangelog)
}

void checkoutBranch(List<String> branchNames, String repository, String targetDir = '', Boolean withChangelog = false) {
    def checkoutInfo = resolveScm(
            source: [$class       : 'GitSCMSource',
                     credentialsId: 'github-company-rapidprofile', id: '_',
                     remote       : "git@github.com:company/${repository}.git",
                     traits       : [[$class: 'CleanAfterCheckoutTrait'],
                                     [$class: 'CleanBeforeCheckoutTrait'],
                                     [$class: 'GitLFSPullTrait'],
                                     [$class: 'jenkins.plugins.git.traits.BranchDiscoveryTrait'],
                                     headWildcardFilter(includes: branchNames.join(' '))]],
            targets: branchNames
    )

    checkoutRevision(checkoutInfo.getBranches().get(0).getName(), repository, targetDir, withChangelog)
}

def checkoutRevision(String revision, String repository, String targetDir = '', Boolean withChangelog = false) {
    def extensions = [[$class: 'CleanCheckout'],
                      [$class: 'CleanBeforeCheckout'],
                      [$class: 'CloneOption', reference: referenceRepository(repository), honorRefspec: true, noTags: true],
                      [$class: 'GitLFSPull']]

    if (withChangelog) {
        extensions << [$class: 'ChangelogToBranch', options: [compareRemote: 'origin', compareTarget: getNextBranch()]]
    }

    dir(targetDir) {
        def checkoutResult = checkout changelog: true, poll: false,
                scm: [$class                           : 'GitSCM',
                      branches                         : [[name: revision]],
                      browser                          : [$class: 'GithubWeb', repoUrl: "http://github.com/company/${repository}"],
                      doGenerateSubmoduleConfigurations: false,
                      extensions                       : extensions,
                      submoduleCfg                     : [],
                      userRemoteConfigs                : [[credentialsId: 'github-company-rapidprofile', url: "git@github.com:company/${repository}.git"]]]
        sshagent(['github-company-rapidprofile']) {
            command 'git -c lfs.concurrenttransfers=50 lfs pull', label: 'Ensure git lfs objects are present'
        }
        return checkoutResult
    }
}

String referenceRepository(String repository) {
    lock("reference-repository-${repository}-${env.NODE_NAME}") {
        dir("${env.HOME}/reference-repositories/${repository}") {
            def workingDir = pwd()
            // If there exists a file called "HEAD" we assume it’s a bare repository
            if (sh(returnStatus: true, script: 'test ! -f HEAD || test ! -d lfs') == 0) {
                command "rm -rf ${env.HOME}/reference-repositories/${repository}/*"
                echo "Mirror ${repository} as reference repository into ${workingDir}"
                sshagent(['github-company-rapidprofile']) {
                    // We use git CLI here because mirror is not supported by the Jenkins plugin
                    // see https://issues.jenkins-ci.org/browse/JENKINS-27191
                    command "git clone --mirror git@github.com:company/${repository} ."
                    command 'git -c lfs.concurrenttransfers=50 lfs pull'
                }
            }

            return workingDir
        }
    }
}

List<String> getBuildProperties() {
    REPOSITORY_REVISION_PROPERTY_MAP.values() + REPOSITORY_BRANCH_PROPERTY_MAP.values() + DEPLOYMENT_PROPERTIES
}

List<String> getPreviousBuildProperties() {
    REPOSITORY_PREVIOUS_REVISION_PROPERTY_MAP.values()
}

void antJob(Map args, String target, String buildFile = 'build.xml') {
    def options = args.options ?: ''
    def sudo = args.sudo ?: false
    withAnt() {
        command "ant -buildfile ${buildFile} ${options} ${target}", sudo: sudo, label: "ant -buildfile ${buildFile} ${options} ${target}"
    }
}

void antJob(String target, String buildFile = 'build.xml') {
    antJob([:], target, buildFile)
}

def getMicrostageHost(String system) {
    def (host, subdomain, tld) = env.MICROSTAGE_HOST.tokenize('.')
    return host + '-' + system + '.' + subdomain + '.' + tld
}

void phpComposerInstall() {
    withCredentials([string(credentialsId: 'github-company-rapidprofile-composer-token', variable: 'GITHUB_COMPOSER_TOKEN')]) {
        command label: 'composer install', '''EXPECTED_CHECKSUM="$(wget -q -O - https://composer.github.io/installer.sig)"
            php -r "copy(\'https://getcomposer.org/installer\', \'composer-setup.php\');"
            ACTUAL_CHECKSUM="$(php -r "echo hash_file(\'sha384\', \'composer-setup.php\');")"

            if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]
            then
                >&2 echo \'ERROR: Invalid installer checksum\'
                rm composer-setup.php
                exit 1
            fi

            php composer-setup.php --quiet
            php -r "unlink(\'composer-setup.php\');"
            php composer.phar config --auth github-oauth.github.com $GITHUB_COMPOSER_TOKEN
            php composer.phar install --no-scripts
            '''
    }
}

@NonCPS
def isJobStartedByTimer() {
    try {
        for (buildCause in currentBuild.getBuildCauses()) {
            if (buildCause != null) {
                if (buildCause.shortDescription.contains("Started by timer")) {
                    echo "Build started by timer"
                    return true
                }
            }
        }
    } catch (e) {
        echo "Error getting build cause: ${e}"
    }
    return false
}

void notifySlackOnFailures(buildStatus, channel) {
    if (isDeployBranch(getBranchName())) {
        def message = "\n ${buildStatus} on stage: ${env.STAGE_NAME} for BRANCH: ${getBranchName()}\n${env.BUILD_URL}"
        slackSend channel: channel, color: 'danger', message: message
    }
}

void notifySlack(buildStatus = 'STARTED', channel = "#monitoring-ci") {
    buildStatus = buildStatus ?: 'STARTED'
    def message = "\n ${buildStatus} on stage: ${env.STAGE_NAME} for BRANCH: ${getBranchName()}\n${env.BUILD_URL}"
    if (buildStatus == 'SUCCESS') {
        slackSend channel: channel, color: 'good', message: message
    } else if (buildStatus == 'UNSTABLE') {
        slackSend channel: channel, color: 'warning', message: message
    } else if (buildStatus == 'STARTED') {
        slackSend channel: channel, color: '#2410F1', message: message
    } else {
        slackSend channel: channel, color: 'danger', message: message
    }
}

void notifySlackAcceptanceTests(summary, stageName) {
    def message = "Acceptance Test Stage: ${env.STAGE_NAME} \n${env.BUILD_URL} \n *Test Summary* - Failures: ${summary.failCount}"
    if (summary.failCount > 0) {
        if (stageName.matches("activity|calendar|common|event-promotion|event-review|group|guestlist|seo") && env.MICROSTAGE != 'true') {
            slackSend channel: "#pxt_drhaus", color: 'danger', message: message
        } else if (stageName.matches("adserver|common|external|forum|profile|registration|registration-workflow|security|smoke|lighthouse|membership|membership-2|membership-creditcard|membership-paypal|membership-paywall|membership-paywall-2|subscription") && env.MICROSTAGE != 'true') {
            // slackSend channel: "#pxt-pokemon", color: 'danger', message: message
        } else if (stageName.matches("networking|spa") && env.MICROSTAGE != 'true') {
            slackSend channel: "#pxt-tetris", color: 'danger', message: message
        } else {
            slackSend channel: "#monitoring-ci", color: 'danger', message: message
        }
    }
}

def notifyGithub(String prefix = null, String stageName = STAGE_NAME, Closure fn) {
    def ordinal
    lock("githubNotifyOrdinal_${env.BUILD_NUMBER}") {
        ordinal = GITHUB_NOTIFY_ORDINAL_NUMBER++
    }

    def path = ['pipeline', String.format('%02d', ordinal), prefix, stageName.toLowerCase().replaceAll(' ', '-')]
    def context = path.findAll({ element -> element != null }).join('/')
    try {
        updateGithubState(context, 'PENDING')
        return fn()
    } finally {
        updateGithubState(context, currentBuild.currentResult)
    }
}

void githubNotifyPipelinePending() {
    updateGithubState('pipeline', 'PENDING')
}

void githubNotifyPipelineCompleted() {
    updateGithubState('pipeline', currentBuild.currentResult)
}

void updateGithubState(String context, String state) {
    if (isDeployBranch(getBranchName())) {
        REPOSITORY_REVISION_PROPERTY_MAP.each { repository, revisionProperty -> setGithubCommitState(repository, env[revisionProperty], state, context) }
    } else {
        REPOSITORY_BRANCH_PROPERTY_MAP.each { repository, branchProperty ->
            if (!isDeployBranch(env[branchProperty])) {
                setGithubCommitState(repository, env[REPOSITORY_REVISION_PROPERTY_MAP[repository]], state, context)
            }
        }
    }
}

void setGithubCommitState(String repository, String revision, String state, String context) {
    // We treat unstable as success in GitHub because GitHub does not have a state between success and failure
    state = state == 'UNSTABLE' ? 'SUCCESS' : state

    step(
            [
                    $class            : "GitHubCommitStatusSetter",
                    reposSource       : [$class: "ManuallyEnteredRepositorySource", url: "https://github.com/company/${repository}"],
                    commitShaSource   : [$class: "ManuallyEnteredShaSource", sha: revision],
                    contextSource     : [$class: "ManuallyEnteredCommitContextSource", context: context],
                    statusResultSource: [$class: "ConditionalStatusResultSource", results: [[$class: "AnyBuildResult", state: state]]]
            ]
    )
}

void buildNodeInfo() {
    echo "Running on node \"${env.NODE_NAME}\" and deploying to \"${env.HUMAN_STAGE_NAME}\""
}

String getBranchName() {
    env.IN_BRANCH_NAME
}

Boolean isDeployBranch(String branchName) {
    return branchName == 'master' || branchName.startsWith('deploy/')
}

Boolean isHotfixBranch(String branchName) {
    return branchName.startsWith('hotfix/')
}

Boolean isDevBranch(String branchName) {
    return branchName.startsWith('dev/')
}

Boolean isDependabotBranch(String branchName) {
    return branchName.startsWith('dependabot/')
}

String getNextBranch() {
    if (!NEXT_BRANCH) {
        NEXT_BRANCH = inGetNextBranch()
    }
    return NEXT_BRANCH
}

List xunitThresholds(failureThreshold = '0') {
    [skipped(unstableThreshold: '0'), failed(unstableThreshold: '0', failureThreshold: failureThreshold.toString())]
}

void command(Map args = [:], String script) {
    script = "${args.sudo ? 'sudo ' : ''}${script}"
    def label = args.label ?: script
    sh label: label, script: script
}

void archiveLogs(String artifacts, String target = '') {
    dir(target) {
        echo "Archive logs \"${artifacts}\" for build #${env.BUILD_NUMBER}"
        archiveArtifacts artifacts: artifacts, fingerprint: false, allowEmptyArchive: true
    }
}

void restoreCurrentBuildLogs(String filter, String target = '') {
    echo "Restore logs matching ${filter} from current build #${env.BUILD_NUMBER}"
    copyArtifacts filter: filter, optional: false, fingerprintArtifacts: false, projectName: env.JOB_NAME, selector: specific(env.BUILD_NUMBER), target: target
}

void archiveBuildDependencies(String artifacts, String target = '') {
    dir(target) {
        echo "Archive artifacts \"${artifacts}\" for build #${env.BUILD_NUMBER}"
        archiveArtifacts artifacts: artifacts, fingerprint: true, allowEmptyArchive: true
    }
}

void restoreCurrentBuildDependencies(String filter, String target = '') {
    echo "Restore artifacts matching \"${filter}\" from current build #${env.BUILD_NUMBER}"
    copyArtifacts filter: filter, optional: false, fingerprintArtifacts: true, projectName: env.JOB_NAME, selector: specific(env.BUILD_NUMBER), target: target
}

void restorePreviousBuildDependencies(String filter, String target = '') {
    echo "Restore artifacts matching \"${filter}\" from previous build"
    copyArtifacts filter: filter, optional: true, fingerprintArtifacts: true, projectName: env.JOB_NAME, selector: lastWithArtifacts(), target: target
}

void setBuildDisplayName() {
    currentBuild.displayName = "${currentBuild.number}-${getBranchName()}"
}

def deploymentMilestone(String label, Integer ordinal) {
    /**
     * From the description: The milestone step forces all builds to go through in order, so an older build will never
     * be allowed pass a milestone (it is aborted) if a newer build already passed it.
     *
     * Since milestones rely on the ordinal number only, this can become an issue in the deploy/NEXT branch. If I have
     * a branch mapped onto a microstage and that build is quicker as the deploy branch, the deploy branch will be
     * aborted. This is why we don't step milestones for microstage deployments on the NEXT branch.
     */
    if (env.MICROSTAGE == 'true' && env.GIT_APP_BRANCH == getNextBranch()) {
        return
    }
    milestone(label: "deploy ${label} to ${env.MICROSTAGE_HOST ?: 'stage'}", ordinal: ordinal)
}

def lockDeployment(String label, fn) {
    lock("deploy-${label}-${env.MICROSTAGE_HOST}") {
        fn()
    }
}

//The first condition needs to be removed once the Jenkinsfile with the new logic in in-frontend has been published

Boolean isFrontendOnly() {
    return (
            !isDeployBranch(getBranchName())
                    && !isDeployBranch(env.GIT_FRONTEND_BRANCH)
                    && !isDeployBranch(env.GIT_APP_BRANCH)
                    && isDeployBranch(env.GIT_SOLR_BRANCH)
                    && isDeployBranch(env.GIT_OMS_BRANCH)
                    && isDeployBranch(env.GIT_CMS_BRANCH)
                    && env.REF == env.REF_CONTAINING_TAG
    )
}

String getTagName(String branchIn) {
    def branch = branchIn.replace("/", "_")
    return "upstream@" + branch
}

def deployService(system, repository, String credentialsName, String paramName) {
    notifyGithub('deploy-services', system) {
        notifySlack()
        buildNodeInfo()
        checkoutRepository repository
        sshagent(['github-company-rapidprofile']) {
            lockDeployment(repository) {
                def stage = 'stage'
                def host = null

                if (env.MICROSTAGE == 'true') {
                    stage = 'microstage'
                    host = getMicrostageHost(system)
                }

                withCredentials([file(credentialsId: "company-${system}-${stage}-${credentialsName}-file", variable: "CREDENTIALS_FILE")]) {
                    withEnv(host ? ["HOSTFILTER=${host}"] : []) {
                        command "cap -s ${paramName}=\$CREDENTIALS_FILE -s branch=\$GIT_${system.toUpperCase()}_REVISION ${system}-${stage} deploy"
                    }
                }
            }
        }
    }
}

def withTestCredentials(Closure fn) {
    withCredentials([
            file(credentialsId: 'company-app-test-env-file', variable: 'company_ENV_FILE'),
            file(credentialsId: 'company-solr-test-properties-file', variable: 'company_SOLR_PROPERTIES_FILE'),
            file(credentialsId: 'company-app-test-properties-file', variable: 'company_PROPERTIES_FILE'),
    ], fn)
}

def withStageCredentials(Closure fn) {
    withCredentials([
            file(credentialsId: 'company-app-microstage-env-file', variable: 'company_ENV_FILE_MICROSTAGE'),
            file(credentialsId: 'company-app-microstage-properties-file', variable: 'company_PROPERTIES_FILE_MICROSTAGE'),
            file(credentialsId: 'company-app-stage-env-file', variable: 'company_ENV_FILE_STAGE'),
            file(credentialsId: 'company-app-stage-properties-file', variable: 'company_PROPERTIES_FILE_STAGE'),
            file(credentialsId: 'company-app-test-properties-file', variable: 'company_PROPERTIES_FILE'),
    ], fn)
}

def withAcceptanceCredentials(Closure fn) {
    withCredentials([
            file(credentialsId: 'company-app-microstage-acceptance-env-file', variable: 'company_ENV_FILE_ACCEPTANCE_MICROSTAGE'),
            file(credentialsId: 'company-app-acc-env-file', variable: 'company_ENV_FILE_ACC'),
            file(credentialsId: 'company-app-test-properties-file', variable: 'company_PROPERTIES_FILE'),
            file(credentialsId: 'company-app-stage-acceptance-env-file', variable: 'company_ENV_FILE_ACCEPTANCE_STAGE'),
    ], fn)
}

void dependabotRequestAutomerge(String repository, String versionRequirement) {
    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
        buildNodeInfo()
        checkoutBranch('master', 'in-kit')
        phpComposerInstall()
        command "php bin/in-kit github:pull-requests:dependabot:request-auto-merge ${repository} ${env.GIT_APP_BRANCH} --${versionRequirement}"
        script { env.DEPENDABOT_AUTOMERGE_REQUESTED = true }
    }
}

void dependabotCancelAutomerge() {
    script {
        if (!env.DEPENDABOT_AUTOMERGE_REQUESTED) {
            return
        }

        node('integration') {
            buildNodeInfo()
            checkoutBranch('master', 'in-kit')
            phpComposerInstall()
            command "php bin/in-kit github:pull-requests:dependabot:cancel-auto-merge in ${env.GIT_APP_BRANCH}"
        }
    }
}

String pluralize(String word, Integer count) {
    // The worlds most naive pluralize function
    return count == 1 ? word : word + 's'
}

void analyzeIssueReport(reports) {
    reports.each { report ->
        if (!report.isSuccessful()) {
            def info = report.sizePerSeverity.collectMany({ severity, size ->
                size > 0 ? ["${size} ${severity.name == 'ERROR' ? pluralize('error', size) :  pluralize('warning', size) + ' of ' + severity.name.toLowerCase() + ' priority'}"] : []
            }).reverse()
            error "${STAGE_NAME} failed and ${info.tail().join(', ')}${info.tail() ? ' and ' : ''}${info.head()} ${info.tail() ? 'were' : 'was'} found. " +
                    'What you need to do exactly depends on the quality gate defined in this step but typically fixing the errors is enough. ' +
                    "Check ${env.BUILD_URL}${report.id} for details."
        }
    }
}

void publishSpaWebpackReport(String context) {
    publishHTML([
            allowMissing: true,
            alwaysLinkToLastBuild: true,
            keepAll: true,
            reportDir: "frontend/.next/analysis/${context}",
            reportFiles: 'report.html',
            reportName: "SPA webpack ${context} report",
            reportTitles: "SPA webpack ${context} report",
    ])
}
