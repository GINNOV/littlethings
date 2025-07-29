import '../styles/globals.css';
import '../styles/App.css';
import { SettingsProvider } from '../src/context/SettingsContext';

function MyApp({ Component, pageProps }) {
  return (
    <SettingsProvider>
      <Component {...pageProps} />
    </SettingsProvider>
  );
}

export default MyApp;
