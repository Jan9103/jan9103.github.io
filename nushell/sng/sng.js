import {g,x} from "/libs/xeact.js";

const db_version = 3;
const os_name = "gpsng";

const show_error=(msg)=>{
  console.error(msg);
  const error_field=g("error");
  const ne=document.createElement("p");
  ne.innerText=msg;
  error_field.appendChild(ne);
};

/// dbname: string
/// url: string
const download=(dbname, url)=>{
  const progress_field=g("progress");
  progress_field.innerText="downloading DB index..";

  const urls=await fetch(url)
    .then((r)=>r.json())
    .catch((err)=>{show_error("Error (fetch db-index): "+err);});
  progress_field.innerText="initializing local database..";
  const idbr=window.indexedDB.open(dbname, db_version);
  idbr.onerror=(event)=>{show_error(`Database error: ${event.target.error?.message}`);};
  idbr.onsuccess=(event)=>{
    const db=event.target.result;
    const os=db.createObjectStore(os_name, { "keyPath": "term" });
    os.createIndex("data", "data", {"unique": false});
    os.transaction.oncomplete=(os_event)=>{
      const osa=db.transaction(os_name, "readwrite").objectStore(os_name);
      for(const i of urls){
        // sync to avoid race-conditions, etc
        const d=await fetch(i)
          .then((r)=>r.json())
          .catch((err)=>{show_error("Error (fetch db-page): "+err);});
        for(const o of d){
          osa.add({"term": o[0], "data": JSON.stringify(o[1])});
        }
      }
    };
  };
};

/// dbname: string
/// terms: array<string>
const search=(dbname, terms)=>{
  
};
