module.exports = {
  dependencies: {
    'rn-in-app-updates': {
      platforms: {
        android: {
          sourceDir: '../android/',
          packageImportPath: 'import pkg.rninappupdates.RnInAppUpdatesPackage;',
          packageInstance: 'new RnInAppUpdatesPackage()',
        },
      },
    },
  },
};