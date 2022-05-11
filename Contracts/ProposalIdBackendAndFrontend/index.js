import Head from 'next/head'
import Image from 'next/image'
import styles from '../styles/Home.module.css'
import {ethers,  providers, Contract, BigNumber} from 'ethers';
import {useState, useEffect, useRef} from "react";
import {web3} from 'web3';
import Web3modal from 'web3modal';
import {FETCHIDADDRESS, FETCHVOTESADDRESS, fetchidabi, fetchvotesabi} from '../constants'
import Hero from '../components/Hero';

export default function Home() {
  const zero = BigNumber.from(0);
  const [isConnected, setIsConnected] = useState(false);
  const [accountAddress, setAccountAddress] = useState('');
  const [loading, setLoading] = useState(false);
  //Dealing with LINK amount 
  const [linkTokens, setLinkTokens] = useState(zero); 
  const [etherBalance, setEtherBalance] = useState(zero);
  //PropsalID
  const[proposalId, setProposalId] = useState("")



  const web3modalref = useRef(); 
  useEffect(() => { 
    web3modalref.current = new Web3modal( { 
        network: "kovan",
        providerOptions: {},
        disableInjectedProvider: false,
    })
    Connect();
  });

  const splitString = (string) => {
    let result1 = string.substring(0,5);
    let result2 = string.substring(38,string.length);
    let finalResult = result1 + "..." + result2;
    return finalResult;
  };
  
  //get provider or signer 
  const getProviderOrSigner = async(needSigner = false) => { 
    const provider = await web3modalref.current.connect(); 
    const web3provider = new providers.Web3Provider(provider);
  
    const signer = web3provider.getSigner(); 
    const address = await signer.getAddress();
    const substringAddress = splitString(address);
    setAccountAddress(substringAddress);
    console.log(substringAddress)

    //check if chainID is kovan 
    const {chainId} = await web3provider.getNetwork(); 
    if(chainId !== 42) { 
      window.alert("You are on the Wrong Network, Swich to Kovan"); 
    }

    if(needSigner) { 
      const signer = web3provider.getSigner();
      return signer;
    }
    return web3provider;
  }
  //connection handler 
  const Connect = async() => { 
    try { 
      await getProviderOrSigner();
      setIsConnected(true);
    }catch(err) { 
      console.error(err);
    }
  }

  //Create a function to fund the contract
  const getLinkBalance = async() => { 
    try { 
      const provider = await getProviderOrSigner(); 
      const contract = new Contract(
        FETCHIDADDRESS,
        fetchidabi,
        provider
      );
      const balance = await contract.returnLinkBalance();
      balance = ethers.utils.formatEther(balance);
      setLinkTokens(balance);
      console.log(balance)
    }catch(err) { 
      console.error(err);
    };
  }
  //function returns balance of ETH in contract
  const returnETH = async() => { 
    try { 
      const provider = await getProviderOrSigner()
      const contract= new Contract(
        FETCHIDADDRESS,
        fetchidabi,
        provider
      );
      const balance = await contract.getBalance();
      balance = ethers.utils.formatEther(balance);
      setEtherBalance(balance);
      console.log(balance)
    }catch(err) { 
      console.error(err);
    }
  }
  //Depost or Send link to contract
  const depositLink = async(tokenAddress, to, from) =>  { 
    try {
      const signer = await getProviderOrSigner(true); 
      const contract = new Contract( 
        FETCHIDADDRESS,
        fetchidabi,
        signer
      );
      //Place in parameters to send Link
      const tx = await contract.transfer(tokenAddress, to, from);
      setLoading(true)
      tx.wait();
      setLoading(false);
    }catch(err) { 
      console.error(err);
    }
  };

  const requestBytes = async() => { 
    try { 
      const signer = await getProviderOrSigner(true); 
      const contract = new Contract(
        FETCHIDADDRESS,
        fetchidabi,
        signer
      );
      const tx = await contract.requestBytes();
      setLoading(true);
      //wait for transaction to get mined
      await tx.wait();
      setLoading(false);

    }catch(err) { 
      console.error(err);
    }

  }









  return (
   <>
    <Head>
      <title>Metal Rentals</title>
      <meta name="description" content="Bridging community and Travel. Find vaction homes, apartments cabins on MetaRentals " />
        <link rel="icon" href="/favicon.ico" />
    </Head>

    <main>
      <Hero />
      <button onClick={returnETH}>Get ETH Balance</button>
      <button onClick={getLinkBalance}>Get Link Balance</button>
      <button onClick={requestBytes}>Request Latest DAO IDs</button>

    </main>
   
   
   </>



  )
}
