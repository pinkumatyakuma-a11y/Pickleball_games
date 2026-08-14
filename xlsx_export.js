(function(){
  "use strict";

  const CDN = "https://cdn.sheetjs.com/xlsx-0.20.3/package/dist/xlsx.full.min.js";

  function loadSheetJS(){
    return new Promise((resolve,reject)=>{
      if(window.XLSX){ resolve(); return; }
      const s=document.createElement("script");
      s.src=CDN;
      s.onload=resolve;
      s.onerror=()=>reject(new Error("Excel出力用ライブラリを読み込めませんでした。"));
      document.head.appendChild(s);
    });
  }

  function tableToAoa(table){
    const rows=[];
    table.querySelectorAll("tr").forEach(tr=>{
      const row=[];
      tr.querySelectorAll("th,td").forEach(cell=>row.push(cell.textContent.trim()));
      rows.push(row);
    });
    return rows;
  }

  function makeMatchSheet(){
    const rows=[["ゲーム","コート","ペア1","ペア2","休み"]];
    document.querySelectorAll("#result .game").forEach((section,gi)=>{
      const rest=(section.querySelector(".rest")||{}).textContent||"";
      const restText=rest.replace(/^休み：/,"").trim();
      section.querySelectorAll(".court").forEach((court,ci)=>{
        const cells=court.querySelectorAll("td");
        if(cells.length>=2){
          rows.push([gi+1,ci+1,cells[0].textContent.trim(),cells[1].textContent.trim(),restText]);
        }
      });
    });
    return rows;
  }

  // 「1 2 3 4」のようなメンバー番号をExcelが日付に自動変換しないよう、
  // 組合せシートの文字列セルを明示的に「文字列」として設定する。
  function forceTextCells(ws, columns){
    const range=XLSX.utils.decode_range(ws["!ref"]||"A1");
    for(let r=range.s.r; r<=range.e.r; r++){
      columns.forEach(c=>{
        const addr=XLSX.utils.encode_cell({r:r,c:c});
        const cell=ws[addr];
        if(cell && cell.v!==undefined){
          cell.t="s";
          cell.v=String(cell.v);
          cell.z="@";
        }
      });
    }
  }

  function makeMatrixSheet(title){
    const heading=[...document.querySelectorAll("#result h2")].find(h=>h.textContent.trim()===title);
    if(!heading) return [[title]];
    const section=heading.closest(".panel");
    const table=section ? section.querySelector("table") : null;
    return table ? tableToAoa(table) : [[title]];
  }

  async function exportExcel(){
    try{
      await loadSheetJS();
      const wb=XLSX.utils.book_new();
      const wsMatch=XLSX.utils.aoa_to_sheet(makeMatchSheet());
      const ws1=XLSX.utils.aoa_to_sheet(makeMatrixSheet("games1"));
      const ws2=XLSX.utils.aoa_to_sheet(makeMatrixSheet("games2"));

      // ペア1・ペア2・休みはすべて「文字列」として保存する。
      // これにより「1 2 3 4」がExcel上で「1月2日」等にならない。
      forceTextCells(wsMatch,[2,3,4]);

      XLSX.utils.book_append_sheet(wb,wsMatch,"組合せ");
      XLSX.utils.book_append_sheet(wb,ws1,"games1");
      XLSX.utils.book_append_sheet(wb,ws2,"games2");

      const nMem=document.getElementById("nMem").value;
      const nCot=document.getElementById("nCot").value;
      const nGame=document.getElementById("nGame").value;
      const fileName=`pickleball_games_${nMem}人_${nCot}面_${nGame}ゲーム.xlsx`;
      XLSX.writeFile(wb,fileName);
    }catch(e){
      const err=document.getElementById("error");
      err.textContent=e.message||"Excel保存に失敗しました。";
    }
  }

  function addButton(){
    const csv=document.getElementById("csv");
    if(!csv || document.getElementById("xlsx")) return;
    const btn=document.createElement("button");
    btn.id="xlsx";
    btn.className="secondary";
    btn.disabled=true;
    btn.textContent="Excel保存";
    btn.addEventListener("click",exportExcel);
    csv.insertAdjacentElement("afterend",btn);

    const make=document.getElementById("make");
    make.addEventListener("click",()=>{
      btn.disabled=!document.querySelector("#result .game");
    });
  }

  if(document.readyState==="loading") document.addEventListener("DOMContentLoaded",addButton);
  else addButton();
})();
