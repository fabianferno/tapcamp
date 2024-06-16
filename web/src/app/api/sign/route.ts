import { NextResponse } from "next/server";
import { ethers } from "ethers";

const sign = async (message: any) => {
  const wallet = new ethers.Wallet("0x" + process.env.PRIVATE_KEY);
  const signature = await wallet.signMessage(message);
  return signature;
};

export async function POST(request: Request) {
  const req = await request.json();
  const { message } = req;

  const result = await sign(message);

  return NextResponse.json(result);
}
