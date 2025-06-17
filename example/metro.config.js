const { resolve } = require('node:path')
const { getDefaultConfig, mergeConfig } = require('@react-native/metro-config')

const projectRoot = __dirname
const workspaceRoot = resolve(projectRoot, '..')

/**
 * Metro configuration
 * https://reactnative.dev/docs/metro
 *
 * @type {import('metro-config').MetroConfig}
 */
const config = {
    resolver: {
        nodeModulesPaths: [
            resolve(projectRoot, 'node_modules'),
        ],
        unstable_enablePackageExports: true,
    },

    server: {
        unstable_serverRoot: projectRoot,
    },

    watchFolders: [workspaceRoot],
}

module.exports = mergeConfig(getDefaultConfig(projectRoot), config)
