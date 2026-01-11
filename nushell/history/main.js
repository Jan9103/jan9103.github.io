import {g,x} from "../../libs/xeact.js";

const ne=(e)=>document.createElement(e);
const cr=async(resp)=>{
  if(!resp.ok){
    throw new Error("Non 2xx response from "+resp.url, {"cause": resp})
  }else{return resp;}
};
const ce=(err)=>{
  console.error('Error',err);
  let m=g("main");
  x(m);
  m.innerText=err;
};

const packages=await fetch("./data/packages.json")
  .then(cr)
  .then((resp)=>resp.json())
  .then((d)=>{
    let pl=g("packages");
    x(pl);
    for(const e of d){
      let n=ne("option");
      n.setAttribute("value", e);
      pl.appendChild(n);
    }
    return d;
  })
  .catch(ce);

const fetch_features=()=>{
  let pk=g("package").value;
  let fl=g("features");
  x(fl);
  if(packages.includes(pk)){
    fetch("./data/"+pk+"/features.json")
      .then(cr)
      .then((resp)=>resp.json())
      .then((d)=>{
        for(const e of d){
          let n=ne("option");
          n.setAttribute("value", e);
          fl.appendChild(n);
        }
      })
      .catch(ce);
  }
};

fetch_features();
g("package").addEventListener("blur",()=>{fetch_features();});

const show_page=(p,f)=>{
  let m=g("main");
  if(!packages.includes(p)){
    x(m);
    m.innerText="Package not found.";
    return;
  }
  fetch("./data/"+p+"/"+encodeURIComponent(f)+".json")
    .then(cr)
    .then((res)=>res.json())
    .then((d)=>{
      console.log(d);
      x(m);
      let n=ne("h1");
      n.innerText=f;
      m.appendChild(n);
      n=ne("h2");
      n.innerText="Changes";
      m.appendChild(n);

      for(const [k,v] of Object.entries(d["changes"])){
        let dn=ne("div");
        n=ne("h3");
        n.innerText=k;
        dn.appendChild(n);
        for(const e of v){
          n=ne("p");
          n.innerText=e;
          dn.appendChild(n);
        }
        m.appendChild(dn);
      }
    })
    .catch(ce);
};

g("open").onclick=()=>{
  console.log("click");
  show_page(g("package").value,g("feature").value);
};
