import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.proedit.studio',
  appName: 'ProEdit Studio',
  webDir: 'out',
  server: {
    androidScheme: 'https'
  },
  android: {
    buildOptions: {
      keystorePath: 'android/app/proedit-studio.keystore',
      keystoreAlias: 'proedit-studio',
      releaseType: 'AAB', // Android App Bundle for Google Play
      signingType: 'apksigner'
    },
    minSdkVersion: 24, // Android 7.0+
    compileSdkVersion: 34,
    targetSdkVersion: 34,
    versionCode: 1,
    versionName: '1.0.0',
    allowMixedContent: false,
    captureInput: true,
    webContentsDebuggingEnabled: false
  },
  plugins: {
    SplashScreen: {
      launchShowDuration: 2000,
      backgroundColor: '#1a1a1a',
      showSpinner: false,
      androidSplashResourceName: 'splash',
      androidScaleType: 'CENTER_CROP',
      splashFullScreen: true,
      splashImmersive: true
    },
    StatusBar: {
      style: 'DARK',
      backgroundColor: '#1a1a1a'
    },
    Keyboard: {
      resize: 'body',
      style: 'dark',
      resizeOnFullScreen: true
    },
    App: {
      launchUrl: '',
      iosCustomApplicationProtocols: ['proedit-studio']
    },
    Permissions: {
      camera: 'This app needs camera access to record videos for editing',
      storage: 'This app needs storage access to save and load video files',
      microphone: 'This app needs microphone access to record audio for videos'
    }
  }
};

export default config;
