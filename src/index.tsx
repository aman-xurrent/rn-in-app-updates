import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'rn-in-app-updates' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const RnInAppUpdates = NativeModules.RnInAppUpdates
  ? NativeModules.RnInAppUpdates
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export interface UpdateInfo {
  isUpdateAvailable: boolean;
  updateUrl?: string;
}

export function checkForUpdate(): Promise<UpdateInfo> {
  return RnInAppUpdates.checkForUpdate();
}

export function updateApp(): Promise<void> {
  return RnInAppUpdates.updateApp();
}
