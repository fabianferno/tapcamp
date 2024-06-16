"use client";
import Image from "next/image";
import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useAccount } from "wagmi";
import { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { ModeToggle } from "@/components/ui/mode-toggle";
import { Badge } from "@/components/ui/badge";
import { IDKitWidget, VerificationLevel } from "@worldcoin/idkit";
import Dashboard from "@/components/Pages/Dashboard";

export default function Home() {
  const [worldcoinId, setWorldcoinId] = useState<any>(null);
  const [worldcoinVerified, setWorldcoinVerified] = useState<boolean>(false);
  const account = useAccount();

  useEffect(() => {
    const signature = localStorage.getItem("worldcoinSignature");
    if (signature) {
      setWorldcoinVerified(true);
      const worldcoinSignature = JSON.parse(signature);
      setWorldcoinId({
        nullifier_hash: worldcoinSignature.message,
      });
      console.log("Loaded worldcoin");
    }
  }, []);

  const handleVerify = async (proof: any) => {
    // console.log(proof);
    const response = await fetch("/api/verify", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ proof }),
    });
    if (!response.ok) {
      throw new Error(`Error verifying Worldcoin: ${response.statusText}`);
    }

    const data = await response.json();
    setWorldcoinVerified(data.verified);
  };

  const handleSign = async (message: string) => {
    const response = await fetch("/api/sign", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ message }),
    });
    if (!response.ok) {
      throw new Error(`Error signing Worldcoin: ${response.statusText}`);
    }

    const signedMessage = await response.json();
    localStorage.setItem(
      "worldcoinSignature",
      JSON.stringify({
        message,
        signature: signedMessage,
      })
    );
  };

  const onSuccess = async (proof: any) => {
    // Sign the verified nullifier hash and store in the localStorage
    await handleSign(proof.nullifier_hash);
    setWorldcoinId(proof);
  };

  useEffect(() => {}, []);

  return (
    <main className="mx-5 flex min-h-screen flex-col items-center justify-center pb-10">
      <div className="absolute top-5 right-5">
        <ModeToggle />
      </div>
      <div className="relative grid grid-cols-1 container place-items-center">
        <Image
          className="relative -mb-3"
          src="/giphy.gif"
          alt="Logo"
          width={250}
          height={250}
          priority
        />
        <div className="text-center mb-5">
          <div className="text-3xl font-bold">
            <span className="flex justify-center items-center">🧑‍💼TapCamp</span>
          </div>
          <div className="font-bold text-zinc-400">
            A social game to connect, earn & win
          </div>
        </div>
      </div>

      <section className="lg:max-w-6xl lg:w-full">
        <div className="ring-1 ring-zinc-700 rounded-xl p-1 w-full">
          {!account?.address ? (
            <div className="flex justify-center items-center flex-col">
              <h3 className="text-md mb-5">
                Connect your wallet to get started
              </h3>
              <ConnectButton />
            </div>
          ) : (
            <div className="flex justify-center items-start flex-col ">
              <div className="flex w-full justify-between items-center">
                <ConnectButton />

                {!worldcoinId ? (
                  <IDKitWidget
                    app_id="app_staging_6885a9ae16c352e8434d6b164197e372" // obtained from the Developer Portal
                    action="verify-human" // this is your action id from the Developer Portal
                    onSuccess={onSuccess} // callback when the modal is closed
                    handleVerify={handleVerify} // optional callback when the proof is received
                    verification_level={VerificationLevel.Device}
                  >
                    {({ open }) => (
                      <Button className="font-bold" onClick={open}>
                        Verify with World ID
                      </Button>
                    )}
                  </IDKitWidget>
                ) : (
                  <div className="text-right mt-1 mr-1">
                    <Badge className="text-xs bg-zinc-400">Worldcoin ✅</Badge>
                    <p className="text-zinc-600 text-xs mt-2 text-right">
                      {worldcoinId.nullifier_hash.slice(0, 12)}
                    </p>
                  </div>
                )}
              </div>

              {account?.address && worldcoinVerified && <Dashboard />}
            </div>
          )}
        </div>
      </section>
    </main>
  );
}
