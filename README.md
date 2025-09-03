# React Native In App Updates
### Overview
The `rn-in-app-updates` npm package is designed to provide a simple and effective solution for performing in-app updates in React Native applications. The methods provided by this package remains consistent across both Android and iOS platforms. In iOS user'll get a bottom drawer sheet opening app store page of the app to update the app manually and in android user'll be shown an immediate popup to update the app.

### New Architecture Support
TODO:
- use `rn-in-app-updates` npm package for old & new architecture support

### Features
Cross-Platform Support: Works seamlessly on both Android and iOS platforms.
Simple Integration: Easily integrate the package by importing and calling checkForUpdate and updateApp async methods.

### Installation
Install the package using npm:
```
npm install rn-in-app-updates
```
### Usage
Import the module in your React Native application and use it like this:

Example App.jsx(javascript)
```
import React, { useEffect } from 'react';
import { View, Text } from 'react-native';
import { checkForUpdate, updateApp } from 'rn-in-app-updates';

const App = () => {
  // To check for app updates on startup
  useEffect(() => {
    const requireAppUpdate = async () => {
      try {
        const { isUpdateAvailable } = await checkForUpdate();
        if (isUpdateAvailable) {
          await updateApp();
        }
      } catch (error) {
        console.log('Update check failed:', error);
      }
    };

    requireAppUpdate();
  }, [loaded]);

  return (
    <View>
      <Text>Some Value.</Text>
      <Text>I use arch btw.</Text>
    </View>
  );
};

export default App;
```

### Contribution
Contributions to the project are welcome! Feel free to create issues or pull requests on the GitHub repository.

### License
This project is licensed under the MIT License.
