#Include "Protheus.ch"
#Include "FWMVCDef.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} User Function CTBINTCPN
    Rotina refaturada da CTBINTCON, a antiga INTERCOMPANY,
    deixando mais a mais clara e mais facil de entendimento
    @type User Function
    @author José Vitor Rodrigue
    @since 31/01/2024
    @version 1
/*/
User Function CTBINTCPN()
    Local aColuna    := {}
    Local aColu      := {}
    Local AliasTemp
    local aCampo     := {}
    Local nX
    Local aPergs     := {}
    Local dDataDe    := FirstDate(Date())
    Local dDataAt    := LastDate(Date())
    Local cFilOri    := Space(6)
    Local cFilDes    := Space(6)
    Local cContDe    := Space(2)
    Local cContAt    := Space(2)
    Local cSpcLot    := Space(6)
    //Janela e componentes
    Private oDlgMk
    Private oPanGd
    Private oBrowse, oBrow
    //Tamanho da janela
    Private aTamanho := MsAdvSize()
    Private nJanLarg := aTamanho[5]
    Private nJanAltu := aTamanho[6]
    //-----------------------------
    Private nQuantas := 0
    Private dDateDe
    Private dDateAt
    Private cFilOr
    Private cFilDe
    Private cConDe
    Private cConAt
    Private cLotCtb
    Private nExiste

    DBSELECTAREA( "SA2" )

    //Adiciona os parâmetros
    aadd(aPergs, {1, "Data Inicial"     , dDataDe, "", ".T.", ""   , ".T.", 50, .T.})
    aadd(aPergs, {1, "Data Final"       , dDataAt, "", ".T.", ""   , ".T.", 50, .T.})
    aadd(aPergs, {1, "Filial de Origem" , cFilOri, "", ".T.", "SM0", ".T.", 50, .T.})
    aadd(aPergs, {1, "Filial de Destino", cFilDes, "", ".T.", "SM0", ".T.", 50, .T.})
    aadd(aPergs, {1, "Controle de"      , cContDe, "", ".T.", ""   , ".T.", 40, .F.})
    aadd(aPergs, {1, "Controle até"     , cContAt, "", ".T.", ""   , ".T.", 40, .F.})
    aadd(aPergs, {1, "Lote contábil"    , cSpcLot, "", ".T.", ""   , ".T.", 40, .T.})
    
    //Se a pergunta foi confirmada
    If ParamBox(aPergs, "Informe os parâmetros", /*aRet*/, /*bOK*/, /*aButtons*/, /*lCentered*/, /*nPosX*/, /*nPosY*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
        dDateDe := SUBSTR(dtoc(mv_par01),7,4)+SUBSTR(dtoc(mv_par01),4,2)+SUBSTR(dtoc(mv_par01),1,2)
        dDateAt := SUBSTR(dtoc(mv_par02),7,4)+SUBSTR(dtoc(mv_par02),4,2)+SUBSTR(dtoc(mv_par02),1,2)
        cFilOr  := mv_par03
        cFilDe  := mv_par04
        cConDe  := mv_par05
        cConAt  := mv_par06
        cLotCtb := mv_par07

        cQuery := " SELECT *  FROM "+ retsqlname("CT2")
        cQuery += " WHERE CT2_FILIAL = "+ cFilDe
        cQuery += " AND CT2_DATA BETWEEN "+ dDateDe+ " AND " +dDateAt
        cQuery += " AND CT2_FILORI = "+cFilOr +" AND CT2_ORIGEM LIKE '%CTBINTER%'"  
        cQuery += " AND D_E_L_E_T_ = '' "
        cQuery += " ORDER BY CT2_ORIGEM"
        TCQuery cQuery NEW ALIAS "VLD"
        
        IF (VLD->(EOF()))
            nExiste := 0
            browserInt()
        ELSE
            nExiste := 1
            msgInfo("Realizado a verificação dos dados inseridos e o sistema localizou Intercompany com eles. Verifique esses dados e clique em continuar para prosseguir com a rotina")

            aadd(aCampo, {"FILIALORI", "C", 06, 00, ""})
            aadd(aCampo, {"FILIALDES", "C", 06, 00, ""})
            aadd(aCampo, {"DATALACTO", "C", 12, 00, ""})
            aadd(aCampo, {"CTDBT"    , "C", 20, 00, ""})
            aadd(aCampo, {"CTCDT"    , "C", 20, 00, ""})
            aadd(aCampo, {"LOTE"     , "C", 06, 00, ""})
            aadd(aCampo, {"VALOR"    , "N", 14, 02, ""})
            aadd(aCampo, {"DOC"      , "C", 06, 00, ""})
            aadd(aCampo, {"HIST"     , "C", 90, 00, ""})
            aadd(aCampo, {"ORIG"     , "C", 90, 00, ""})

            AliasTemp   := GetNextAlias()
            oTempTable := FWTemporaryTable():New(AliasTemp)
            oTemptable:SetFields(aCampo)
            oTempTable:Create()

            While !(VLD->(EOF()))
                if reclock((AliasTemp),.T.)
                    (AliasTemp)->FILIALORI := VLD->CT2_FILORI 
                    (AliasTemp)->FILIALDES := VLD->CT2_FILIAL 
                    (AliasTemp)->DATALACTO := SUBSTR(VLD->CT2_DATA,7,2)+ '/' +SUBSTR(VLD->CT2_DATA,5,2)+ '/' +SUBSTR(VLD->CT2_DATA,1,4)
                    (AliasTemp)->CTDBT     := VLD->CT2_DEBITO
                    (AliasTemp)->CTCDT     := VLD->CT2_CREDIT
                    (AliasTemp)->LOTE      := VLD->CT2_LOTE
                    (AliasTemp)->VALOR     := VLD->CT2_VALOR
                    (AliasTemp)->DOC       := VLD->CT2_DOC
                    (AliasTemp)->HIST      := VLD->CT2_HIST
                    (AliasTemp)->ORIG      := VLD->CT2_ORIGEM
                    (AliasTemp)->(dbunlock())  
                ENDIF
                VLD->(DBSKIP())
            EndDo

            aadd(aColu, {"FILIALORI", "FILIAL ORIGEM"          , "C", 00, 00, ""})
            aadd(aColu, {"FILIALDES", "FILIAL DESTINO"         , "C", 00, 00, ""})
            aadd(aColu, {"DATALACTO", "DATA LANÇAMENTO"        , "C", 00, 00, ""})
            aadd(aColu, {"CTDBT"    , "CONTA DEBITO"           , "C", 20, 00, ""})
            aadd(aColu, {"CTCDT"    , "CONTA CREDITO"          , "C", 20, 00, ""})
            aadd(aColu, {"LOTE"     , "LOTE"                   , "C", 00, 00, ""})
            aadd(aColu, {"VALOR"    , "VALOR"                  , "C", 00, 02, ""})
            aadd(aColu, {"DOC"      , "DOCUMENTO"              , "C", 00, 00, ""})
            aadd(aColu, {"HIST"     , "HISTORICO"              , "C", 00, 00, ""})
            aadd(aColu, {"ORIG"     , "ORIGEM"                 , "C", 00, 00, ""})
        
            For nX := 1 To Len(aColu)    
                AAdd(aColuna,FWBrwColumn():New())
                aColuna[Len(aColuna)]:SetData( &("{||"+aColu[nX][1]+"}") )
                aColuna[Len(aColuna)]:SetTitle(aColu[nX][2])
                aColuna[Len(aColuna)]:SetSize(aColu[nX][4])
                aColuna[Len(aColuna)]:SetDecimal(aColu[nX][5])              
                aColuna[Len(aColuna)]:SetPicture(aColu[nX][6])              
            Next nX       
            DEFINE MSDIALOG oDlgMk TITLE '' FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
                //Dados
                oPanGd := tPanel():New(001, 001, '', oDlgMk, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2)-1,     (nJanAltu/2 - 1))
                //Criando o FWMarkBrowse
                oBrowse := FWMBrowse():New()
                oBrowse:SetAlias((AliasTemp))               
                oBrowse:SetDescription("Verifição do Intercompany")
                oBrowse:SetColumns(aColuna)
                oBrowse:AddButton("CONTINUAR",{|| browserInt()},,3,,.F.)
                oBrowse:AddButton("Cancelar", {|| oDlgMk:end() },,4,,.F.)
                oBrowse:SetTemporary(.T.)
                oBrowse:SetOwner(oPanGd)
                oBrowse:DisableDetails()
                    
                //Ativando a janela
                oBrowse:Activate()
            ACTIVATE MsDialog oDlgMk CENTERED
            oBrowse:DeActivate()   
        ENDIF
        
    EndIf

Return 

/*/{Protheus.doc} browserInt
    Função para chamr o browser do Intecompany
    @type  Static Function
    @author José Vitor Rodrigues
    @since 06/02/2024
    @version 1.0
/*/
Static Function browserInt()
    Local aColunas  := {}
    Local aCol      := {}
    Local nX
    Private AliasTMP
    Private aCampos   := {}

    //Adicionando o campo da tabela temporária
    aadd(aCampos, {"FILIALORI", "C", 06, 00})
    aadd(aCampos, {"FILIALDES", "C", 06, 00})
    aadd(aCampos, {"DATALACTO", "D", 08, 00})
    aadd(aCampos, {"DEBITO"   , "C", 20, 00})
    aadd(aCampos, {"CREDITO"  , "C", 20, 00})
    aadd(aCampos, {"DEBITO1"  , "C", 20, 00})
    aadd(aCampos, {"CREDITO1" , "C", 20, 00})
    aadd(aCampos, {"LOTE"     , "C", 06, 00})
    aadd(aCampos, {"SUBLOTE"  , "C", 06, 00})
    aadd(aCampos, {"DOC"      , "C", 06, 00})
    aadd(aCampos, {"EMPORI"   , "C", 06, 00})
    aadd(aCampos, {"LINHA"    , "C", 03, 00})
    aadd(aCampos, {"DC"       , "C", 03, 00})
    aadd(aCampos, {"MOEDLC "  , "C", 06, 00})
    aadd(aCampos, {"VALOR "   , "N", 14, 02})
    aadd(aCampos, {"HP "      , "C", 20, 00})
    aadd(aCampos, {"CLVLDB1"  , "C", 15, 00})
    aadd(aCampos, {"CLVLCR1"  , "C", 15, 00})
    aadd(aCampos, {"HIST "    , "C", 99, 00})
    aadd(aCampos, {"SEQHIS "  , "C", 40, 00})
    aadd(aCampos, {"TPSALD "  , "C", 40, 00})
    aadd(aCampos, {"CCD "     , "C", 09, 00})
    aadd(aCampos, {"CCC "     , "C", 09, 00})
    aadd(aCampos, {"ITEMD "   , "C", 40, 00})
    aadd(aCampos, {"ITEMC "   , "C", 40, 00})
    aadd(aCampos, {"CLVLDB2"  , "C", 15, 00})
    aadd(aCampos, {"CLVLCR2"  , "C", 15, 00})
    aadd(aCampos, {"SEQLAN "  , "C", 40, 00})
    aadd(aCampos, {"ROTINA "  , "C", 40, 00})
    aadd(aCampos, {"MANUAL "  , "C", 40, 00})
    aadd(aCampos, {"AGLUT "   , "C", 40, 00})
    aadd(aCampos, {"TAXA "    , "N", 08, 04})
    aadd(aCampos, {"VLR01 "   , "N", 14, 02})
    aadd(aCampos, {"VLR02 "   , "N", 14, 02})
    aadd(aCampos, {"VLR03 "   , "N", 14, 02})
    aadd(aCampos, {"VLR04 "   , "N", 14, 02})
    aadd(aCampos, {"VLR05 "   , "N", 14, 02})
    aadd(aCampos, {"CRCONV "  , "C", 40, 00})
    aadd(aCampos, {"INTERC "  , "C", 06, 00})
    aadd(aCampos, {"EC05CR "  , "C", 40, 00})
    aadd(aCampos, {"EC05DB "  , "C", 40, 00})
    aadd(aCampos, {"ORIGEM "  , "C", 99, 00})
    aadd(aCampos, {"CTDBT "   , "C", 60, 00})
    aadd(aCampos, {"CTCDT "   , "C", 60, 00})

    //Criando a tabela temporária
    AliasTMP   := GetNextAlias()
    oTempTable := FWTemporaryTable():New(AliasTMP)
    oTemptable:SetFields(aCampos)
    oTempTable:Create()
    Processa({|lEnd| INTERCPN()})  
    //Adicionando o campo da coluna do brownse
    aadd(aCol, {"FILIALORI", "FILIAL ORIGEM"          , "C", 00, 00, ""})
    aadd(aCol, {"FILIALDES", "FILIAL DESTINO"         , "C", 00, 00, ""})
    aadd(aCol, {"DATALACTO", "DATA LANÇAMENTO"        , "C", 00, 00, ""})
    aadd(aCol, {"CTDBT"    , "CONTA DEBITO"           , "C", 40, 00, ""})
    aadd(aCol, {"CTCDT"    , "CONTA CREDITO"          , "C", 40, 00, ""})
    aadd(aCol, {"LOTE"     , "LOTE"                   , "C", 00, 00, ""})
    aadd(aCol, {"LINHA"    , "LINHA"                  , "C", 00, 00, ""})
    aadd(aCol, {"VALOR"    , "VALOR"                  , "C", 00, 00, ""})
    aadd(aCol, {"DOC"      , "DOCUMENTO"              , "C", 00, 00, ""})
    aadd(aCol, {"HIST"     , "HISTORICO"              , "C", 00, 00, ""})
    
    For nX := 1 To Len(aCol)    
        AAdd(aColunas,FWBrwColumn():New())
        aColunas[Len(aColunas)]:SetData( &("{||"+aCol[nX][1]+"}") )
        aColunas[Len(aColunas)]:SetTitle(aCol[nX][2])
        aColunas[Len(aColunas)]:SetSize(aCol[nX][4])
        aColunas[Len(aColunas)]:SetDecimal(aCol[nX][5])              
        aColunas[Len(aColunas)]:SetPicture(aCol[nX][6])              
    Next nX       
    //Criando o FWMarkBrowse
    oBrow := FWMBrowse():New()
    oBrow:SetAlias((AliasTMP))               
    oBrow:SetDescription("Processamento Intercompany - linhas totais: "+CVALTOCHAR( nQuantas ))
    oBrow:AddLegend("DEBITO != DEBITO1 .AND. CREDITO != CREDITO1","BLUE","CONTA DEBITO E CREDITO COM ALTERAÇÃO")
    oBrow:AddLegend("DEBITO != DEBITO1","YELLOW","CONTA DEBITO ALTERADO")
    oBrow:AddLegend("CREDITO != CREDITO1","ORANGE","CONTA CREDITO ALTERADO")
    oBrow:AddLegend("DEBITO == DEBITO1 .AND. CREDITO == CREDITO1","GREEN","CONTA DEBITO/CREDITO SEM ALTERAÇÃO")
    oBrow:SetColumns(aColunas)
    oBrow:AddButton("Executar",{|| FWMsgRun(, {|oSay| EXECINTER(oSay) }, "Processando", "Processando dados")} ,,3,,.F.)
    oBrow:AddButton("Cancelar", {|| fecharBrowser()},,4,,.F.)
    oBrow:SetTemporary(.T.)
    oBrow:DisableDetails()
        
    //Ativando a janela
    oBrow:Activate()       
Return 
/*/{Protheus.doc} fecharBrowser
    Rotina para realizar o fechamento dos dois browsers
    @type  Static Function
    @author Jose Vitor Rodrigues
    @since 07/02/2024
    @version 1.0
/*/
Static Function fecharBrowser()
    CloseBrowse()
    if(nExiste == 1)
        oDlgMk:end() 
    endif
Return 
/*/{Protheus.doc} INTERCPN
    Função que irá executar o intercompany
    entre as filiais
    @type  Static Function
    @author José Vitor Rodrigues
    @since 31/01/2024
    @version 1.0
/*/
Static Function INTERCPN()
    Private dData     //variavel da data do lançamento
    Private cLote     //variavel do numero do lote do Intercomny
    Private cSub      //variavel do Sub Lote
    Private cDoc      //Variavel do Numero do Documento
    Private cZZSDes1  //Variavel do número da conta de debito
    Private cZZSDes2  //Variavel do número da conta de crédito
    Private nPercDes1 //Variavel do 1° Percentual DE da ZZS
    Private nPercDes2 //Variavel do 2° Percentual DE da ZZS
    Private nZZS1     //Variavel do Percentual De da ZZS
    Private nZZS2     //Variavel do Percentual De da ZZS
    Private cLinha    //Variavel do Número da linha
    Private cFilOri   //Variável da Filial original do lançamento
    Private cEmpOri   //Variável da Empresa original do lançamento
    Private cDc       //Variável do Tipo do Lancamento
    Private nDebito   //Variável da conta de débito
    Private nCredit   //Variável da conta de crédito
    Private nValor    //Variável do valor do lançamento
    Private nValor1    //Variável do valor do lançamento
    Private cMoeda    //Variável da moeda do lançamento
    Private cHp       //Variável do histórico padrão
    Private cCLDB     //Variável da Classe Valor Debito
    Private cCLCR     //Variável da Classe Valor Crédito
    Private cClasse   //Variável responsável por definir qual será a classe(Debito ou Credito)
    Private cHist     //Variável do histórico do lançamento
    Private cSeq      //Variavel do Link entre CTK e CT2
    Private cTpsld    //Variável do tipo de Saldo
    Private cSeqLan   //Variável da Seq Auxiliar do Lancto
    Private cRotina   //Variavel da Rotina Geradora do Lançamento
    Private cManual   //Variável para saber se é lançamento manual
    Private cAglut    //Variável do Lancamento aglutinado
    Private nTaxa     //Variável da Taxa Conversao do lançamento
    Private nVlr01    //Variável do Valor Lançamento Moeda 1
    Private nVlr02    //Variável do Valor Moeda 2
    Private nVlr03    //Variável do Valor Moeda 3
    Private nVlr04    //Variável do Valor Moeda 4
    Private nVlr05    //Variável do Valor Moeda 5
    Private cCrconv   //Variável do Criterio de Conversao
    Private cCCD      //Variável do Centro de Custo Debito
    Private cCCC      //Variavel do Centro de Custo Credor
    Private cITEMD    //Variavel do Item Debito
    Private cITEMC    //Variavel do Item Credito
    Private cCLVLDB   //Variavel da Classe Valor Debito
    Private cCLVLCR   //Variavel da Classe Valor Credito
    Private cEC05CR
    Private cEC05DB 
    Private nDocum
    Private nCtDebO
    Private nCtCdtO

    /*Realiza a consulta na CT2 na qual traz todos os dados da condição da busca que a CT2_FILIAL deve ser igual a de cFilOr,
    o CT2_DATA deve estar entre a dDateDe(inicial) e a dDateAt(final), D_E_L_E_T_ = ' ' e o valor da CT2_INTERC ser igual a 1 e nos ambos os caso serão ordenados
    por CT2_FILIAL e CT2_DATA
    */
    cQuery          := " SELECT * FROM "+retsqlname("CT2")
    cQuery          += " WHERE CT2_FILIAL = '" + cFilOr + "' "
    cQuery          += " AND CT2_DATA BETWEEN '" + dDateDe + "' AND '"+dDateAt + "' "
    cQuery          += " AND D_E_L_E_T_ = ' ' AND CT2_INTERC = '1' ORDER BY CT2_FILIAL, CT2_DATA "
    TCQuery cQuery NEW ALIAS "TCCT2"

    cLinha          := 1 //Agora é definido a variavel cLinha como 1                       
    nDocum          := VAL(cLotCtb)+1 //define nDocum como o valor numerico do cLotCtb + 1

    //Seleciona a consulta realizado anteriormentee coloca os valores no top da consula
    dbSelectArea("TCCT2")
    TCCT2->(dbGotop())

    //Percorre a consulta até chegar no final
    While TCCT2->(!EOF())
        Incproc("Selecionando lançamentos...")
        //Define a variavel com os valores da CT2_DATA
        dData           := CtoD(SUBSTR(TCCT2->CT2_DATA,7,2)+ '/' +SUBSTR(TCCT2->CT2_DATA,5,2)+ '/' +SUBSTR(TCCT2->CT2_DATA,1,4))
        cLote           := cLotCtb //definindo o valor do lote com o numero que foi preenchido
        cSub            := '001' //define o cSub como 001
        cDoc            := Strzero(nDocum,6) //Converte o nDocum em uma String com 6 caracteres e salva no nDoc
        cZZSDes1        := '' //Define o cZZSDes1, numero da conta de debito , como vazio
        cZZSDes2        := '' //Define o cZZSDes2, numero da conta de credito , como vazio
        nPercDes1       := 0 //Define o nPercDes1, , como 0
        nPercDes2       := 0 //Define o nPercDes2, , como 0       
        nZZS1           := 0 //Define o nZZS1, , como 0
        nZZS2           := 0 //Define o nZZS2, , como 0
        cLinha          := TCCT2->CT2_LINHA //define o valor da cLinha com o valor obtido na CT2_LINHA
        cFilOri         := TCCT2->CT2_FILORI //define o valor da cFilOri com o valor obtido na CT2_FILORI, referindo-se ao valor da filial de origem
        cEmpOri         := TCCT2->CT2_EMPORI //define o valor da cEmpOri com o valor obtido na CT2_EMPORI, referindo-se a Empresa de Origem do Lançamento
        cDc             := TCCT2->CT2_DC //define o valor da cDc com o valor obtido na CT2_DC, refere-se ao Tipo do Lancamento
        nDebito         := TCCT2->CT2_DEBITO //define o valor da nDebito com o valor obtido na CT2_DEBITO, refere-se a conta de débito
        nCredit         := TCCT2->CT2_CREDIT //define o valor da nCredit com o valor obtido na CT2_CREDIT, refere-se a conta de crédito
        nValor          := TCCT2->CT2_VALOR //define o valor da nValor com o valor obtido na CT2_VALOR, refere-se ao Valor do Lancamento
        cMoeda          := '01' //Define a cMoeda como 01
        cHP             := TCCT2->CT2_HP //Define o cHp como CT2_HP, referindo-se ao Historico Padrao
        cCLDB           := TCCT2->CT2_CLVLDB //Define o cCLDB como CT2_CLVLDB, refere-se ao Classe Valor Debito
        cCLCR           := TCCT2->CT2_CLVLCR //define o cCLCR como CT2_CLVLCR, refere-se ao Classe Valor Credito
        cClasse         := cCLDB
        If cCLDB <> cCLCR //realiza a verrificação se a variavel cCLDB é diferente da cCLCR se for entrará na condição do if
            if empty(cCLCR)//em seguida realiza outra verificação e verifica se a variavel cCLCR está vazia
                cClasse         := cCLDB //caso verdadeiro define o valor da cClasse como cCLDB
            Else
                cClasse         := cCLCR //caso falso define o valor da cClasse como cCLCR
            Endif
        Endif
        cHist   := TCCT2->CT2_HIST    //Define o cHist   como CT2_HIST, refere-se ao Historico Lcto
        cSeqH   := TCCT2->CT2_SEQHIS  //Define o cSeqH   como CT2_SEQHIS, refere-se ao Link entre CTK e CT2
        cTpsld  := TCCT2->CT2_TPSALD  //Define o cTpsld  como CT2_TPSALD, refere-se ao Tipo do Saldo?
        cSeqLan := TCCT2->CT2_SEQLAN  //Define o cSeqLan como CT2_SEQLAN, refere-se ao Seq Auxiliar do Lancto
        cRotina := TCCT2->CT2_ROTINA  //Define o cRotina como CT2_ROTINA, refere-se ao Rotina Geradora
        cManual := TCCT2->CT2_MANUAL  //Define o cManual como CT2_MANUAL, refere-se ao Eh lcto Manual?
        cAglut  := TCCT2->CT2_AGLUT   //Define o cAglut  como CT2_AGLUT, refere-se ao Lancamento aglutinado
        nTaxa   := TCCT2->CT2_TAXA    //Define o nTaxa   como CT2_TAXA, refere-se ao Taxa Conversao
        nVlr01  := TCCT2->CT2_VLR01   //Define o nVlr01  como CT2_VLR01, refere-se ao Valor Lançamento Moeda 1
        nVlr02  := TCCT2->CT2_VLR02   //Define o nVlr02  como CT2_VLR02, refere-se ao Valor Moeda 2
        nVlr03  := TCCT2->CT2_VLR03   //Define o nVlr03  como CT2_VLR03, refere-se ao Valor Moeda 3
        nVlr04  := TCCT2->CT2_VLR04   //Define o nVlr04  como CT2_VLR04, refere-se ao Valor Moeda 4
        nVlr05  := TCCT2->CT2_VLR05   //Define o nVlr05  como CT2_VLR05, refere-se ao Valor Moeda 5
        cCrconv := TCCT2->CT2_CRCONV  //Define o cCrconv como CT2_CRCONV, refere-se ao Criterio de Conversao
        cCCD    := TCCT2->CT2_CCD     //Define o cCCD    como CT2_CCD, refere-se ao Centro de Custo Debito
        cCCC    := TCCT2->CT2_CCC     //Define o cCCC    como CT2_CCC, refere-se ao Centro de Custo Credor
        cITEMD  := TCCT2->CT2_ITEMD   //Define o cITEMD  como CT2_ITEMD, refere-se ao Item Debito
        cITEMC  := TCCT2->CT2_ITEMC   //Define o cITEMC  como CT2_ITEMC, refere-se ao Item Credito
        cCLVLDB := TCCT2->CT2_CLVLDB  //Define o cCLVLDB como CT2_CLVLDB, refere-se ao Classe Valor Debito
        cCLVLCR := TCCT2->CT2_CLVLCR  //Define o cCLVLCR como CT2_CLVLCR, refere-se ao Classe Valor Credito

        //Na variavel cEC05CR será salvo o valor do posicionamento da Tabela CV0 no indice 4 com o valor da variavel de destino
        //retornado o código
        cEC05CR         := POSICIONE( 'CV0' ,4,cFilDe, 'CV0_CODIGO' ) // cFilDe       // NESSE CASO ESSE ENTIDADE SEMPRE COMEÇA POR 01
        cEC05DB         := cEC05CR // cFilDe       // NESSE CASO ESSE ENTIDADE SEMPRE COMEÇA POR 01

        /*
        Agora irá realizar uma consulta retornando todos os valores da tabela ZZS, onde o valor da filial de origem é igual
        ao parametro digitado na pergunta ou seja ZZS_FILORI = '"+cFilOr+"' e a filial de destino seja tambem igual ao
        parametro digitado na pergunta, ZZS_FILDES = '"+cFilDe+"' ", em seguida verifica a conta de origem seja igual a
        variavel definida anteriormente nDebito ZZS_CTAORI = '"+nDebito+"', após isso é definido o espaço do controle sera analizado
        pegando as variaveis digitadas nas pergunta e por fim pega os valores que não foram deletado. A consulta será ordenada pelos
        primeiro por ZZS_CTAORI e depois por ZZS_CTADES
        */
        cQuery2         := " SELECT * FROM "+retsqlname("ZZS")
        cQuery2         += " WHERE ZZS_FILORI = '"+cFilOr+"' AND ZZS_FILDES = '"+cFilDe+"' "
        cQuery2         += " AND ZZS_CTAORI = '"+nDebito+"' "
        cQuery2         += " AND ZZS_CTRL >= '"+cConDe+"' AND ZZS_CTRL <= '"+cConAt+"' "
        cQuery2         += " AND D_E_L_E_T_ = '' "
        cQuery2         += " ORDER BY ZZS_CTAORI, ZZS_CTADES"
        TCQuery cQuery2 NEW ALIAS "TCZZS"

        //Agora irá selecionar a consulta feita
        dbSelectArea("TCZZS")
        COUNT TO nRecCount1//realizará a contagem dos valores e salvando-os na variavel nRecCount1

        If nRecCount1 > 0 // verifica a contagem se é maior que 0 se for entrará na condição
            TCZZS->(dbGotop()) // Irá definir para apontar no valor do topo da tabela
            nPercDes1       := TCZZS->ZZS_PERCDE //define a variavel nPercDes1 como ZZS_PERCDE, referindo ao percentual De
            cZZSDes1        := trim(TCZZS->ZZS_CTADES) //define a variavel cZZSDes1 como ZZS_PERCDE, referindo a conta de destino
            nZZS1           := TCZZS->ZZS_PERCDE//define a variavel nZZS1 como ZZS_PERCDE, referindo ao percentual De
            nZZS2           := TCZZS->ZZS_PERCATE//define a variavel nZZS2 como ZZS_PERCDE, referindo ao percentual Ate
            nCtDebO         := TCZZS->ZZS_CTAORI
        Else
            nCtDebO         := nDebito
            cZZSDes1        := nDebito // se nRecCount1 for igual a 0, irá definir o valor do cZZSDes1 como nDebito
        EndIf
        TCZZS->(dbCloseArea())

        // Será feito um condulta parecido com a anterior mudando somente o valor da ZZS_CTAORI que ao invés de ser a de débito será a de crédito
        cQuery2         := " SELECT * FROM "+retsqlname("ZZS")
        cQuery2         += " WHERE ZZS_FILORI = '"+cFilOr+"' AND ZZS_FILDES = '"+cFilDe+"' "
        cQuery2         += " AND ZZS_CTAORI = '"+nCredit+"' "
        cQuery2         += " AND ZZS_CTRL >= '"+cConDe+"' AND ZZS_CTRL <= '"+cConAt+"' "
        cQuery2         += " AND D_E_L_E_T_ = '' "
        cQuery2         += " ORDER BY ZZS_CTAORI, ZZS_CTADES"
        TCQuery cQuery2 NEW ALIAS "TCZZS"

        //Será selecionado novamente a area da consulta com os novos valores
        dbSelectArea("TCZZS")
        COUNT TO nRecCount2 //em seguida é realizado a contação da quantidade de valores da consulta salvando na variavel nRecCount2
        //Irá verificar se nRecCount2 é maior que 0
        If nRecCount2 > 0
            TCZZS->(dbGotop())//Aponta a consulta para o topo
            nPercDes2       := TCZZS->ZZS_PERCDE //define a variavel nPercDes2 como ZZS_PERCDE, referindo ao percentual De
            cZZSDes2        := trim(TCZZS->ZZS_CTADES)//define a variavel cZZSDes2 como ZZS_PERCDE, referindo a conta de destino
            nZZS1           := TCZZS->ZZS_PERCDE//define a variavel nZZS1 como ZZS_PERCDE, referindo ao percentual De
            nZZS2           := TCZZS->ZZS_PERCATE//define a variavel nZZS2 como ZZS_PERCDE, referindo ao percentual Ate
            nCtCdtO         := TCZZS->ZZS_CTAORI
        Else
            nCtCdtO         := nCredit
            cZZSDes2        := nCredit// se nRecCount1 for igual a 0, irá definir o valor do cZZSDes2 como nDebito
        EndIf
        TCZZS->(dbCloseArea())

        // Se não encontrou registros na ZZS, pula para o próximo registro da CT2.
        If nRecCount1 = 0 .AND. nRecCount2 = 0
            TCCT2->(DBSKIP())
            Loop
        EndIf
        //   If (cFilOr = '79' .AND. cFilDe = '71')  .and. (!empty(cClasse))
        If (cFilOr = FORMULA( 'F79' ) .AND. cFilDe = FORMULA( 'F71' )) .and. (!empty(cClasse))
            //Se caso for da filial 79 a de origem e a 71 de destino e a cClasse ser vazia
            /*
            Irá realizar uma consulta de toods os dados da SD2 onde a filial seja igual a filial de origem digitado
            na pergunta, o D2_CLVL seja igual a varialvel cClasse definida anteriormente e  que não tenha nenhum 
            dados deletado, por fim realizará a ordenação da tabela pelo campo D2_EMISSAO só que por descrescente
            */
            cQueryD2        := " SELECT * FROM "+retsqlname("SD2")
            cQueryD2        += " WHERE D2_FILIAL = '"+cFilOr+"' AND D2_CLVL = '"+cClasse+"' "
            cQueryD2        += " AND D_E_L_E_T_ = '' "
            cQueryD2        += " ORDER BY D2_EMISSAO DESC"

            TCQuery cQueryD2 NEW ALIAS "TCSD2"
        
            //Realizado a seleção da area gerada pela consulta
            dbSelectArea("TCSD2")
            COUNT TO nRecCount //realizará a contagem das linhas da consulta e salvar na nRecCount
            
            //verifica se o nRecCount não é igual a 0
            If nRecCount > 0
                DbGoTop()//Aponta a consulta para o topo
                If (TCSD2->D2_COMIS1 == 3.65) .or. (TCSD2->D2_COMIS1 == 3.90) // verificarpa se o valor da D2_COMIS1 é igual a 3.65 ou se é igual 3.90
                    nPercDes1       := nZZS1 //TCZZS->ZZS_PERCDE //se for define o nPercDes1 como nZZS1
                Elseif (TCSD2->D2_COMIS1 == 0) // se o D2_COMIS1 for igual a 0
                    nPercDes1       := FORMULA( 'P01' ) // 15.70 //Definirá o valor nPercDes1 como o valor da formula P01 que é 0
                Elseif (TCSD2->D2_COMIS1 == 4.15)// se o D2_COMIS1 é igaul a 4.15
                    nPercDes1       := nZZS2 //TCZZS->ZZS_PERCATE // definirá o valor do nPercDes1 como nZZS2
                Endif
            EndIf
            TCSD2->(dbCloseArea())
        Endif
        
        //verifica a variavel cCLDB junto com a cCLCR sem os espaço é igual a '' se for entrá na condição do if
        If (trim(cCLDB)+trim(cCLCR))= ''
            If nPercDes1 > 0 .and. nPercDes2 > 0 //agora realizará outro if para verificar se o nPercDes1 é > 0 e o nPercDes2 é > 0
                If nPercDes1 < nPercDes2 // se for realizará outro if verificando se o nPercDes1 < nPercDes2
                    nValor1         := ((nValor * nPercDes1)/100) //se for definirá  o nValor1 como ((nValor * nPercDes1)/100)
                Else
                    nValor1         := ((nValor * nPercDes2)/100)//caso for igual ou o nPercDes2 for maior  definirá como ((nValor * nPercDes2)/100)
                Endif
            Else
                If nPercDes1 > 0  //caso nPercDes1 e nPercDes2 maior que 0 irá verificar se o nPercDes1 é maior que 0
                    nValor1         := ((nValor * nPercDes1)/100) //se for definirá  o nValor1 como ((nValor * nPercDes1)/100)
                ElseIf nPercDes2 > 0 // ira verificar se o nPercDes2 é maior que 0 
                    nValor1         := ((nValor * nPercDes2)/100) //se for definirá  o nValor1 como ((nValor * nPercDes1)/100)
                EndIf
            Endif
        Else // caso o valor de (trim(cCLDB)+trim(cCLCR)) não for '' 
            nValor1         := ((nValor * nPercDes1)/100)  //define o valor de nValor1 como ((nValor * nPercDes1)/100)
        Endif

        dbSelectArea((AliasTMP))
        //irá verificar se o nPercDes1 é maior q 0  ou se o nPercDes2 é maior que 0 e se o valor arredondado de nValor1 é maior que 0
        If (nPercDes1 > 0 .or. nPercDes2 > 0 ) .and. round(nValor1,2) > 0
            if reclock((AliasTMP),.T.) //chama para realizar a inclusão na tabela CT2

                (AliasTMP)->FILIALDES := cFilDe  //Define a inclusão da CT2_FILIAL como cFilDe
                (AliasTMP)->DATALACTO := dData     //Define a inclusão da CT2_DATA como dData
                (AliasTMP)->LOTE   := cLote     //Define a inclusão da CT2_LOTE como cLote
                (AliasTMP)->SUBLOTE := cSub      //Define a inclusão da CT2_SBLOTE como cSub
                (AliasTMP)->DOC    := cDoc      //Define a inclusão da CT2_DOC    como cDoc   
                (AliasTMP)->LINHA  := cLinha    //Define a inclusão da CT2_LINHA  como cLinha 
                (AliasTMP)->FILIALORI := cFilOri   //Define a inclusão da CT2_FILORI como cFilOri
                (AliasTMP)->EMPORI := cEmpOri   //Define a inclusão da CT2_EMPORI como cEmpOri
                (AliasTMP)->DC     := cDc       //Define a inclusão da CT2_DC     como cDc     
                if nPercDes1 > 0
                    (AliasTMP)->DEBITO  := cZZSDes1 //Define a inclusão da CT2_DEBITO como cZZSDes1
                    (AliasTMP)->DEBITO1 := nCtDebO //Define a inclusão da CT2_DEBITO como cZZSDes1
                    (AliasTMP)->CTDBT   := 'FILIAL ORIGEM: '+Alltrim(nCtDebO)+' -> FILIAL DESTINO: '+Alltrim(cZZSDes1)
                Else
                    (AliasTMP)->CTDBT   := 'FILIAL ORIGEM: '+Alltrim(nCtDebO)+' -> FILIAL DESTINO: '+Alltrim(nDebito)
                    (AliasTMP)->DEBITO1 := nCtDebO
                    (AliasTMP)->DEBITO  := nDebito //Define a inclusão da CT2_DEBITO como nDebito
                Endif
                if nPercDes2 > 0
                    (AliasTMP)->CTCDT    := 'FILIAL ORIGEM: '+Alltrim(nCtCdtO)+' -> FILIAL DESTINO: '+Alltrim(cZZSDes2)
                    (AliasTMP)->CREDITO1 := nCtCdtO
                    (AliasTMP)->CREDITO  := cZZSDes2 //Define a inclusão da CT2_CREDIT como cZZSDes2
                Else
                    (AliasTMP)->CTCDT   := 'FILIAL ORIGEM: '+Alltrim(nCtCdtO)+' -> FILIAL DESTINO: '+Alltrim(nCredit)
                    (AliasTMP)->CREDITO1 := nCtCdtO
                    (AliasTMP)->CREDITO  := nCredit //Define a inclusão da CT2_CREDIT como nCredit
                Endif
                (AliasTMP)->MOEDLC := cMoeda    //Define a inclusão da CT2_MOEDLC como cMoeda 
                (AliasTMP)->VALOR  := nValor1   //Define a inclusão da CT2_VALOR  como nValor1
                (AliasTMP)->HP     := cHp       //Define a inclusão da CT2_HP     como cHp    
                (AliasTMP)->CLVLDB1 := cCLDB     //Define a inclusão da CT2_CLVLDB como cCLDB  
                (AliasTMP)->CLVLCR1 := cCLCR     //Define a inclusão da CT2_CLVLCR como cCLCR  
                (AliasTMP)->HIST   := cHist     //Define a inclusão da CT2_HIST   como cHist  
                (AliasTMP)->SEQHIS := cSeqH     //Define a inclusão da CT2_SEQHIS como cSeqH  
                (AliasTMP)->TPSALD := cTpsld    //Define a inclusão da CT2_TPSALD como cTpsld 
                (AliasTMP)->CCD    := cCCD      //Define a inclusão da CT2_CCD    como cCCD   
                (AliasTMP)->CCC    := cCCC      //Define a inclusão da CT2_CCC    como cCCC   
                (AliasTMP)->ITEMD  := cITEMD    //Define a inclusão da CT2_ITEMD  como cITEMD 
                (AliasTMP)->ITEMC  := cITEMC    //Define a inclusão da CT2_ITEMC  como cITEMC 
                (AliasTMP)->CLVLDB2 := cCLVLDB   //Define a inclusão da CT2_CLVLDB como cCLVLDB
                (AliasTMP)->CLVLCR2 := cCLVLCR   //Define a inclusão da CT2_CLVLCR como cCLVLCR
                (AliasTMP)->SEQLAN := cSeqLan   //Define a inclusão da CT2_SEQLAN como cSeqLan
                (AliasTMP)->ROTINA := cRotina   //Define a inclusão da CT2_ROTINA como cRotina
                (AliasTMP)->MANUAL := cManual   //Define a inclusão da CT2_MANUAL como cManual
                (AliasTMP)->AGLUT  := cAglut    //Define a inclusão da CT2_AGLUT  como cAglut 
                (AliasTMP)->TAXA   := nTaxa     //Define a inclusão da CT2_TAXA   como nTaxa  
                (AliasTMP)->VLR01  := nVlr01    //Define a inclusão da CT2_VLR01  como nVlr01 
                (AliasTMP)->VLR02  := nVlr02    //Define a inclusão da CT2_VLR02  como nVlr02 
                (AliasTMP)->VLR03  := nVlr03    //Define a inclusão da CT2_VLR03  como nVlr03 
                (AliasTMP)->VLR04  := nVlr04    //Define a inclusão da CT2_VLR04  como nVlr04 
                (AliasTMP)->VLR05  := nVlr05    //Define a inclusão da CT2_VLR05  como nVlr05 
                (AliasTMP)->CRCONV := cCrconv   //Define a inclusão da CT2_CRCONV como cCrconv
                (AliasTMP)->INTERC := '2'       //Define a inclusão da CT2_INTERC como '2'    
                (AliasTMP)->EC05CR := cEC05CR   //Define a inclusão da CT2_EC05CR como cEC05CR
                (AliasTMP)->EC05DB := cEC05DB   //Define a inclusão da CT2_EC05DB como cEC05DB
                (AliasTMP)->ORIGEM := 'CTBINTER->INTEGRAÇÃO INTERCOMPANCT2_ORIGEMY' //Define a inclusão da  como 'CTBINTER->INTEGRAÇÃO INTERCOMPANCT2_ORIGEMY'
                    
                nQuantas++ //Define a nQuantas como nQuantas + 1 
                nDocum++  //Define nDocum  como nDocum + 1
                (AliasTMP)->(dbunlock()) //fecha a tabela CT2 para a inclusao de dados
            EndIf
            cLinha          := strzero(val(cLinha) + 1,3) // define o valor da cLinha como strzero(val(cLinha) + 1,3)
        EndIf
        TCCT2->(DBSKIP()) //Irá para o proximo valor da TCCT2
    Enddo
    
    TCCT2->(dbCloseArea()) //Irá fechar a TCCT2

    

Return 
/*/{Protheus.doc} EXECINTER
    Função responsável por realizar o intercompany
    @type  Static Function
    @author José Vitor Rodrigues
    @since 06/02/2024
    @version 1.0
    @param oSay, object, parametro responsável por dizer as mensagem do processa()
/*/
Static Function EXECINTER(oSay)
    //Agora irá selecionar a tabela CT2
    dbSelectArea((AliasTMP))
    (AliasTMP)->(dbGotop())
    nQuantas := 0
    While (AliasTMP)->(!EOF())
        dbSelectArea("CT2")
        if reclock("CT2",.T.) //chama para realizar a inclusão na tabela CT2
            CT2->CT2_FILIAL := (AliasTMP)->FILIALDES  //Define a inclusão da CT2_FILIAL como _FilDest
            CT2->CT2_DATA   := (AliasTMP)->DATALACTO     //Define a inclusão da CT2_DATA como dData
            CT2->CT2_LOTE   := (AliasTMP)->LOTE     //Define a inclusão da CT2_LOTE como cLote
            CT2->CT2_SBLOTE := (AliasTMP)->SUBLOTE      //Define a inclusão da CT2_SBLOTE como cSub
            CT2->CT2_DOC    := (AliasTMP)->DOC      //Define a inclusão da CT2_DOC    como cDoc   
            CT2->CT2_LINHA  := (AliasTMP)->LINHA    //Define a inclusão da CT2_LINHA  como cLinha 
            CT2->CT2_FILORI := (AliasTMP)->FILIALORI   //Define a inclusão da CT2_FILORI como cFilOri
            CT2->CT2_EMPORI := (AliasTMP)->EMPORI   //Define a inclusão da CT2_EMPORI como cEmpOri
            CT2->CT2_DC     := (AliasTMP)->DC       //Define a inclusão da CT2_DC     como cDc     
            CT2->CT2_DEBITO := (AliasTMP)->DEBITO //Define a inclusão da CT2_DEBITO como cZZSDes1
            CT2->CT2_CREDIT := (AliasTMP)->CREDITO   //Define a inclusão da CT2_CREDIT como cZZSDes2
            CT2->CT2_MOEDLC := (AliasTMP)->MOEDLC  //Define a inclusão da CT2_MOEDLC como cMoeda 
            CT2->CT2_VALOR  := (AliasTMP)->VALOR   //Define a inclusão da CT2_VALOR  como nValor1
            CT2->CT2_HP     := (AliasTMP)->HP      //Define a inclusão da CT2_HP     como cHp    
            CT2->CT2_CLVLDB := (AliasTMP)->CLVLDB1 //Define a inclusão da CT2_CLVLDB como cCLDB  
            CT2->CT2_CLVLCR := (AliasTMP)->CLVLCR1 //Define a inclusão da CT2_CLVLCR como cCLCR  
            CT2->CT2_HIST   := (AliasTMP)->HIST    //Define a inclusão da CT2_HIST   como cHist  
            CT2->CT2_SEQHIS := (AliasTMP)->SEQHIS  //Define a inclusão da CT2_SEQHIS como cSeqH  
            CT2->CT2_TPSALD := (AliasTMP)->TPSALD  //Define a inclusão da CT2_TPSALD como cTpsld 
            CT2->CT2_CCD    := (AliasTMP)->CCD     //Define a inclusão da CT2_CCD    como cCCD   
            CT2->CT2_CCC    := (AliasTMP)->CCC     //Define a inclusão da CT2_CCC    como cCCC   
            CT2->CT2_ITEMD  := (AliasTMP)->ITEMD   //Define a inclusão da CT2_ITEMD  como cITEMD 
            CT2->CT2_ITEMC  := (AliasTMP)->ITEMC   //Define a inclusão da CT2_ITEMC  como cITEMC 
            CT2->CT2_CLVLDB := (AliasTMP)->CLVLDB2 //Define a inclusão da CT2_CLVLDB como cCLVLDB
            CT2->CT2_CLVLCR := (AliasTMP)->CLVLCR2 //Define a inclusão da CT2_CLVLCR como cCLVLCR
            CT2->CT2_SEQLAN := (AliasTMP)->SEQLAN  //Define a inclusão da CT2_SEQLAN como cSeqLan
            CT2->CT2_ROTINA := (AliasTMP)->ROTINA  //Define a inclusão da CT2_ROTINA como cRotina
            CT2->CT2_MANUAL := (AliasTMP)->MANUAL  //Define a inclusão da CT2_MANUAL como cManual
            CT2->CT2_AGLUT  := (AliasTMP)->AGLUT   //Define a inclusão da CT2_AGLUT  como cAglut 
            CT2->CT2_TAXA   := (AliasTMP)->TAXA    //Define a inclusão da CT2_TAXA   como nTaxa  
            CT2->CT2_VLR01  := (AliasTMP)->VLR01   //Define a inclusão da CT2_VLR01  como nVlr01 
            CT2->CT2_VLR02  := (AliasTMP)->VLR02   //Define a inclusão da CT2_VLR02  como nVlr02 
            CT2->CT2_VLR03  := (AliasTMP)->VLR03   //Define a inclusão da CT2_VLR03  como nVlr03 
            CT2->CT2_VLR04  := (AliasTMP)->VLR04   //Define a inclusão da CT2_VLR04  como nVlr04 
            CT2->CT2_VLR05  := (AliasTMP)->VLR05   //Define a inclusão da CT2_VLR05  como nVlr05 
            CT2->CT2_CRCONV := (AliasTMP)->CRCONV  //Define a inclusão da CT2_CRCONV como cCrconv
            CT2->CT2_INTERC := (AliasTMP)->INTERC  //Define a inclusão da CT2_INTERC como '2'    
            CT2->CT2_EC05CR := (AliasTMP)->EC05CR  //Define a inclusão da CT2_EC05CR como cEC05CR
            CT2->CT2_EC05DB := (AliasTMP)->EC05DB  //Define a inclusão da CT2_EC05DB como cEC05DB
            CT2->CT2_ORIGEM := (AliasTMP)->ORIGEM  //Define a inclusão da  como 'CTBINTER->INTEGRAÇÃO INTERCOMPANCT2_ORIGEMY'
            CT2->(dbunlock())    
            nQuantas        := nQuantas + 1 //Define a nQuantas como nQuantas + 1 
        EndIf
        (AliasTMP)->(DBSKIP())
    Enddo

    //Exibirpa a mensagem de processo finalizado
    msgInfo("Processo Finalizado! Integrados "+ALLTRIM(str(nQuantas,5))+ ' lançamentos. Execute o Reprocessamento em seguida para atualização dos SALDOS Contábeis.' )
    //Abrirá a tela de Reprocessamento de saldo
    CTBA190()
    //para fechar o browser depois
    fecharBrowser()
Return 

