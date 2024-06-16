declare class NDEFReader {
  constructor();
  scan: () => Promise<void>;
  write: (message: any) => Promise<void>;
  onreading: (event: any) => void;
  onreadingerror: (event: any) => void;
}
