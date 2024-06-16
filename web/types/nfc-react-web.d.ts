declare module "nfc-react-web" {
  interface NfcProps {
    read: (data: any) => void;
    timeout?: number;
  }

  export default class Nfc extends React.Component<NfcProps> {}
}
