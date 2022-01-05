export const OMNIDEF = {"userTimeZone":-480,"userProfile":"Google System Admin","userName":"abhaydilip@google.com.fiberv3.devpro","userId":"0055Y00000HPbn3QAD","userCurrencyCode":"USD","timeStamp":"2022-01-04T13:52:09.607Z","sOmniScriptId":"a3N8G000000GpnyUAC","sobjPL":{},"RPBundle":"","rMap":{},"response":null,"propSetMap":{"stepChartPlacement":"right","scrollBehavior":"smooth","mergeSavedData":false,"currentLanguage":"en_US","stylesheet":{"newportRtl":"","newport":"","lightningRtl":"","lightning":""},"disableUnloadWarn":true,"errorMessage":{"custom":[]},"consoleTabIcon":"custom:custom18","consoleTabTitle":null,"rtpSeed":false,"showInputWidth":false,"currencyCode":"","autoFocus":false,"pubsub":false,"message":{},"ssm":false,"wpm":false,"consoleTabLabel":"New","cancelRedirectTemplateUrl":"vlcCancelled.html","cancelRedirectPageName":"OmniScriptCancelled","cancelSource":"%ContextId%","allowCancel":true,"cancelType":"SObject","visualforcePagesAvailableInPreview":{},"hideStepChart":true,"timeTracking":false,"knowledgeArticleTypeQueryFieldsMap":{},"lkObjName":null,"bLK":false,"enableKnowledge":false,"trackingCustomData":{},"seedDataJSON":{},"elementTypeToHTMLTemplateMapping":{},"autoSaveOnStepNext":false,"saveURLPatterns":{},"saveObjectId":"%ContextId%","saveContentEncoded":false,"saveForLaterRedirectTemplateUrl":"vlcSaveForLaterAcknowledge.html","saveForLaterRedirectPageName":"sflRedirect","saveExpireInDays":null,"saveNameTemplate":null,"allowSaveForLater":true,"persistentComponent":[{"sendJSONPath":"","sendJSONNode":"","responseJSONPath":"","responseJSONNode":"","render":false,"remoteTimeout":30000,"remoteOptions":{"preTransformBundle":"","postTransformBundle":""},"remoteMethod":"","remoteClass":"","preTransformBundle":"","postTransformBundle":"","modalConfigurationSetting":{"modalSize":"lg","modalHTMLTemplateId":"vlcProductConfig.html","modalController":"ModalProductCtrl"},"label":"","itemsKey":"cartItems","id":"vlcCart"},{"render":false,"remoteTimeout":30000,"remoteOptions":{"preTransformBundle":"","postTransformBundle":""},"remoteMethod":"","remoteClass":"","preTransformBundle":"","postTransformBundle":"","modalConfigurationSetting":{"modalSize":"lg","modalHTMLTemplateId":"","modalController":""},"label":"","itemsKey":"knowledgeItems","id":"vlcKnowledge","dispOutsideOmni":false}]},"prefillJSON":"{}","lwcId":"a627db4f-a5bf-1e86-5722-9f4e3abeaf11","labelMap":{"zipcode":"CustomerInformation:AddressInformationBlock:zipcode","stateValue":"CustomerInformation:AddressInformationBlock:stateValue","cityValue":"CustomerInformation:AddressInformationBlock:cityValue","unitNumberValue":"CustomerInformation:AddressInformationBlock:unitNumberValue","streetValue":"CustomerInformation:AddressInformationBlock:streetValue","email":"CustomerInformation:PersonalInformationBlock:email","phone":"CustomerInformation:PersonalInformationBlock:phone","lastName":"CustomerInformation:PersonalInformationBlock:lastName","firstName":"CustomerInformation:PersonalInformationBlock:firstName","AddressInformationBlock":"CustomerInformation:AddressInformationBlock","PersonalInformationBlock":"CustomerInformation:PersonalInformationBlock","AddressServiceability":"CustomerSearch:AddressServiceability","LeadRecordNavigate":"LeadRecordNavigate","ticketCreation":"ticketCreation","AddressReviewTicket":"AddressReviewTicket","CreatePremisesAndLeadRecord":"CreatePremisesAndLeadRecord","MarketAndTitleValue":"MarketAndTitleValue","UserEmail":"UserEmail","CustomerInformation":"CustomerInformation","CustomerSearch":"CustomerSearch","setProfileDetails":"setProfileDetails"},"labelKeyMap":{},"errorMsg":"","error":"OK","dMap":{},"depSOPL":{},"depCusPL":{},"cusPL":{},"children":[{"type":"Set Values","propSetMap":{"wpm":false,"ssm":false,"showPersistentComponent":[false,false],"show":null,"pubsub":false,"message":{},"label":null,"elementValueMap":{"isTechnician":"=IF(%userProfile% = 'Technician', '', 'true')"},"disOnTplt":false,"controlWidth":12,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"setProfileDetails","level":0,"indexInParent":0,"bHasAttachment":false,"bEmbed":false,"bSetValues":true,"JSONPath":"setProfileDetails","lwcId":"lwc0"},{"type":"Step","propSetMap":{"wpm":false,"validationRequired":true,"ssm":false,"showPersistentComponent":[true,false],"show":null,"saveMessage":"Are you sure to check this address","saveLabel":"","remoteTimeout":30000,"remoteOptions":{},"remoteMethod":"","remoteClass":"","pubsub":false,"previousWidth":0,"previousLabel":"","nextWidth":0,"nextLabel":"","message":{},"label":null,"knowledgeOptions":{"typeFilter":"","remoteTimeout":30000,"publishStatus":"Online","language":"English","keyword":"","dataCategoryCriteria":""},"instructionKey":"","instruction":"","errorMessage":{"default":null,"custom":[]},"conditionType":"Hide if False","completeMessage":"Are you sure you want to complete the script?","completeLabel":"Complete","chartLabel":null,"cancelMessage":"Are you sure?","cancelLabel":"","businessEvent":"","businessCategory":"","allowSaveForLater":true,"HTMLTemplateId":"","uiElements":{"CustomerSearch":""},"aggElements":{"AddressServiceability":""}},"offSet":0,"name":"CustomerSearch","level":0,"indexInParent":1,"bHasAttachment":false,"bEmbed":false,"response":null,"inheritShowProp":null,"children":[{"response":null,"level":1,"indexInParent":0,"eleArray":[{"type":"Custom Lightning Web Component","rootIndex":1,"response":null,"propSetMap":{"show":null,"lwcName":"addressServiceability","label":null,"hide":false,"disOnTplt":false,"customAttributes":[{"source":"CustomerInformation","name":"nextstep"},{"source":"%userProfile%","name":"profile"},{"source":"%isTechnician%","name":"is-Technician"},{"source":"%historyEventId%","name":"history-Id"}],"controlWidth":12,"conditionType":"Hide if False","bStandalone":false},"name":"AddressServiceability","level":1,"JSONPath":"CustomerSearch:AddressServiceability","indexInParent":0,"index":0,"children":[],"bHasAttachment":false,"bcustomlightningwebcomponent1":true,"lwcId":"lwc10-0"}],"bHasAttachment":false}],"bAccordionOpen":false,"bAccordionActive":false,"bStep":true,"isStep":true,"JSONPath":"CustomerSearch","lwcId":"lwc1"},{"type":"Step","propSetMap":{"wpm":false,"validationRequired":true,"ssm":false,"showPersistentComponent":[false,false],"show":null,"saveMessage":"Are you sure you want to save it for later?","saveLabel":"","remoteTimeout":30000,"remoteOptions":{},"remoteMethod":"","remoteClass":"","pubsub":false,"previousWidth":3,"previousLabel":"Previous","nextWidth":3,"nextLabel":"Next","message":{},"label":"Customer Information","knowledgeOptions":{"typeFilter":"","remoteTimeout":30000,"publishStatus":"Online","language":"English","keyword":"","dataCategoryCriteria":""},"instructionKey":"","instruction":"","errorMessage":{"default":null,"custom":[]},"disOnTplt":false,"conditionType":"Hide if False","completeMessage":"Are you sure you want to complete the script?","completeLabel":"Complete","chartLabel":null,"cancelMessage":"Are you sure?","cancelLabel":"","allowSaveForLater":true,"HTMLTemplateId":"","uiElements":{"CustomerInformation":"","firstName":"","lastName":"","phone":"","email":"","PersonalInformationBlock":"","streetValue":"","unitNumberValue":"","cityValue":"","stateValue":"","zipcode":"","AddressInformationBlock":""},"aggElements":{}},"offSet":0,"name":"CustomerInformation","level":0,"indexInParent":2,"bHasAttachment":false,"bEmbed":false,"response":null,"inheritShowProp":null,"children":[{"response":null,"level":1,"indexInParent":0,"eleArray":[{"type":"Block","rootIndex":2,"response":null,"propSetMap":{"bus":true,"show":null,"repeatLimit":null,"repeatClone":false,"repeat":false,"label":null,"hide":false,"disOnTplt":false,"controlWidth":12,"conditionType":"Hide if False","collapse":false,"accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"PersonalInformationBlock","level":1,"JSONPath":"CustomerInformation:PersonalInformationBlock","indexInParent":0,"index":0,"children":[{"response":null,"level":2,"indexInParent":0,"eleArray":[{"type":"Text","rootIndex":2,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"required":true,"repeatLimit":null,"repeatClone":false,"repeat":false,"readOnly":false,"ptrnErrText":"","pattern":"","minLength":0,"maxLength":255,"mask":"","label":"First Name","inputWidth":12,"hide":false,"helpText":"","help":false,"disOnTplt":false,"defaultValue":null,"debounceValue":0,"controlWidth":6,"conditionType":"Hide if False","accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"firstName","level":2,"JSONPath":"CustomerInformation:PersonalInformationBlock|1:firstName","indexInParent":0,"index":0,"children":[],"bHasAttachment":false,"bText":true,"lwcId":"lwc2000-0"}],"bHasAttachment":false},{"response":null,"level":2,"indexInParent":1,"eleArray":[{"type":"Text","rootIndex":2,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"required":true,"repeatLimit":null,"repeatClone":false,"repeat":false,"readOnly":false,"ptrnErrText":"","pattern":"","minLength":0,"maxLength":255,"mask":"","label":"Last Name","inputWidth":12,"hide":false,"helpText":"","help":false,"disOnTplt":false,"defaultValue":null,"debounceValue":0,"controlWidth":6,"conditionType":"Hide if False","accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"lastName","level":2,"JSONPath":"CustomerInformation:PersonalInformationBlock|1:lastName","indexInParent":1,"index":0,"children":[],"bHasAttachment":false,"bText":true,"lwcId":"lwc2001-0"}],"bHasAttachment":false},{"response":null,"level":2,"indexInParent":2,"eleArray":[{"type":"Telephone","rootIndex":2,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"required":false,"repeatLimit":null,"repeatClone":false,"repeat":false,"readOnly":false,"ptrnErrText":"","pattern":"","minLength":0,"maxLength":255,"mask":"(999) 999-9999","label":"Phone","inputWidth":12,"hide":false,"helpText":"","help":false,"disOnTplt":false,"defaultValue":null,"debounceValue":0,"controlWidth":6,"conditionType":"Hide if False","accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"phone","level":2,"JSONPath":"CustomerInformation:PersonalInformationBlock|1:phone","indexInParent":2,"index":0,"children":[],"bHasAttachment":false,"bTelephone":true,"lwcId":"lwc2002-0"}],"bHasAttachment":false},{"response":null,"level":2,"indexInParent":3,"eleArray":[{"type":"Email","rootIndex":2,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"required":false,"repeatLimit":null,"repeatClone":false,"repeat":false,"readOnly":false,"ptrnErrText":"","pattern":"","label":"Email","inputWidth":12,"hide":false,"helpText":"","help":false,"disOnTplt":false,"defaultValue":null,"debounceValue":0,"controlWidth":6,"conditionType":"Hide if False","accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"email","level":2,"JSONPath":"CustomerInformation:PersonalInformationBlock|1:email","indexInParent":3,"index":0,"children":[],"bHasAttachment":false,"bEmail":true,"lwcId":"lwc2003-0"}],"bHasAttachment":false}],"bHasAttachment":false,"bBlock":true,"lwcId":"lwc20-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":1,"eleArray":[{"type":"Block","rootIndex":2,"response":null,"propSetMap":{"bus":true,"show":null,"repeatLimit":null,"repeatClone":false,"repeat":false,"label":null,"hide":false,"disOnTplt":false,"controlWidth":12,"conditionType":"Hide if False","collapse":false,"accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"AddressInformationBlock","level":1,"JSONPath":"CustomerInformation:AddressInformationBlock","indexInParent":1,"index":0,"children":[{"response":null,"level":2,"indexInParent":0,"eleArray":[{"type":"Text","rootIndex":2,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"required":false,"repeatLimit":null,"repeatClone":false,"repeat":false,"readOnly":false,"ptrnErrText":"","pattern":"","minLength":0,"maxLength":255,"mask":"","lwcComponentOverride":"","label":"Street","inputWidth":12,"hide":false,"helpText":"","help":false,"disOnTplt":false,"defaultValue":"%addressInfoResponse:street%","debounceValue":0,"controlWidth":6,"conditionType":"Hide if False","accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"streetValue","level":2,"JSONPath":"CustomerInformation:AddressInformationBlock|1:streetValue","indexInParent":0,"index":0,"children":[],"bHasAttachment":false,"bText":true,"lwcId":"lwc2100-0"}],"bHasAttachment":false},{"response":null,"level":2,"indexInParent":1,"eleArray":[{"type":"Text","rootIndex":2,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"required":false,"repeatLimit":null,"repeatClone":false,"repeat":false,"readOnly":false,"ptrnErrText":"","pattern":"","minLength":0,"maxLength":255,"mask":"","label":"Unit Number","inputWidth":12,"hide":false,"helpText":"","help":false,"disOnTplt":false,"defaultValue":"%addressInfoResponse:unitNumber%","debounceValue":0,"controlWidth":6,"conditionType":"Hide if False","accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"unitNumberValue","level":2,"JSONPath":"CustomerInformation:AddressInformationBlock|1:unitNumberValue","indexInParent":1,"index":0,"children":[],"bHasAttachment":false,"bText":true,"lwcId":"lwc2101-0"}],"bHasAttachment":false},{"response":null,"level":2,"indexInParent":2,"eleArray":[{"type":"Text","rootIndex":2,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"required":false,"repeatLimit":null,"repeatClone":false,"repeat":false,"readOnly":false,"ptrnErrText":"","pattern":"","minLength":0,"maxLength":255,"mask":"","label":"City","inputWidth":12,"hide":false,"helpText":"","help":false,"disOnTplt":false,"defaultValue":"%addressInfoResponse:city%","debounceValue":0,"controlWidth":6,"conditionType":"Hide if False","accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"cityValue","level":2,"JSONPath":"CustomerInformation:AddressInformationBlock|1:cityValue","indexInParent":2,"index":0,"children":[],"bHasAttachment":false,"bText":true,"lwcId":"lwc2102-0"}],"bHasAttachment":false},{"response":null,"level":2,"indexInParent":3,"eleArray":[{"type":"Text","rootIndex":2,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"required":true,"repeatLimit":null,"repeatClone":false,"repeat":false,"readOnly":false,"ptrnErrText":"","pattern":"","minLength":0,"maxLength":255,"mask":"","label":"State","inputWidth":12,"hide":false,"helpText":"","help":false,"disOnTplt":false,"defaultValue":"%addressInfoResponse:state%","debounceValue":0,"controlWidth":6,"conditionType":"Hide if False","accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"stateValue","level":2,"JSONPath":"CustomerInformation:AddressInformationBlock|1:stateValue","indexInParent":3,"index":0,"children":[],"bHasAttachment":false,"bText":true,"lwcId":"lwc2103-0"}],"bHasAttachment":false},{"response":null,"level":2,"indexInParent":4,"eleArray":[{"type":"Text","rootIndex":2,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"required":true,"repeatLimit":null,"repeatClone":false,"repeat":false,"readOnly":false,"ptrnErrText":"","pattern":"","minLength":0,"maxLength":255,"mask":"","label":"Zipcode","inputWidth":12,"hide":false,"helpText":"","help":false,"disOnTplt":false,"defaultValue":"%addressInfoResponse:zip5%","debounceValue":0,"controlWidth":6,"conditionType":"Hide if False","accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"zipcode","level":2,"JSONPath":"CustomerInformation:AddressInformationBlock|1:zipcode","indexInParent":4,"index":0,"children":[],"bHasAttachment":false,"bText":true,"lwcId":"lwc2104-0"}],"bHasAttachment":false}],"bHasAttachment":false,"bBlock":true,"lwcId":"lwc21-0"}],"bHasAttachment":false}],"bAccordionOpen":false,"bAccordionActive":false,"bStep":true,"isStep":true,"JSONPath":"CustomerInformation","lwcId":"lwc2"},{"type":"DataRaptor Extract Action","propSetMap":{"wpm":false,"validationRequired":"Step","ssm":false,"showPersistentComponent":[false,false],"show":null,"responseJSONPath":"","responseJSONNode":"","remoteTimeout":30000,"redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"postMessage":"Done","message":{},"label":"Author email","inProgressMessage":"In Progress","ignoreCache":false,"failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"disOnTplt":false,"dataRaptor Input Parameters":[{"inputParam":"userId","element":"userId"}],"controlWidth":12,"bundle":"LDM_ExtractUser","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"UserEmail","level":0,"indexInParent":3,"bHasAttachment":false,"bEmbed":false,"bDataRaptorExtractAction":true,"JSONPath":"UserEmail","lwcId":"lwc3"},{"type":"Set Values","propSetMap":{"wpm":false,"ssm":false,"showPersistentComponent":[false,false],"show":null,"pubsub":false,"message":{},"label":"ADR_MarketAndTitle","elementValueMap":{"title":"='Sandbox: '+IF(%unitNumberValue%=NULL,'',%unitNumberValue%)+' '+%streetValue%+' '+%cityValue%+' '+%stateValue%+' '+%zipcode%+' USA'","marketValueTicket":"=IF(%cityValue%='Atlanta','ATL',IF(%cityValue%='Austin','AUS',IF(%cityValue%='Charlotte','CLT',IF(%cityValue%='Huntersville','HSV',IF(%cityValue%='Nashville','BNA',IF(%cityValue%='Orange County','IRV',IF(%cityValue%='Provo','PVU',IF(%cityValue%='Salt Lake City','SLC',IF(%cityValue%='San Antonio','SAT',IF(%cityValue%='The Triangle','RDU',''))))))))))","marketValue":"=IF(%cityValue%='Atlanta','Atlanta, GA',IF(%cityValue%='Austin','Austin, TX',IF(%cityValue%='Charlotte','Charlotte, NC',IF(%cityValue%='Huntersville','Huntsville, AL',IF(%cityValue%='Nashville','Nashville, TN',IF(%cityValue%='Orange County','Orange County, CA',IF(%cityValue%='Provo','Provo, UT',IF(%cityValue%='Salt Lake City','Salt Lake City, UT',IF(%cityValue%='San Antonio','San Antonio, TX',IF(%cityValue%='The Triangle','Raleigh/Durham, NC',''))))))))))"},"disOnTplt":false,"controlWidth":12,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"MarketAndTitleValue","level":0,"indexInParent":4,"bHasAttachment":false,"bEmbed":false,"bSetValues":true,"JSONPath":"MarketAndTitleValue","lwcId":"lwc4"},{"type":"Integration Procedure Action","propSetMap":{"wpm":false,"validationRequired":"Step","useContinuation":false,"svgSprite":"","svgIcon":"","ssm":false,"showPersistentComponent":[false,false],"show":null,"sendJSONPath":"","sendJSONNode":"","responseJSONPath":"","responseJSONNode":"","remoteTimeout":30000,"remoteOptions":{"useFuture":false,"preTransformBundle":"","postTransformBundle":"","chainable":false},"redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"preTransformBundle":"","postTransformBundle":"","postMessage":"Done","message":{},"label":"ADR_CreatePremisesLeadRecord","integrationProcedureKey":"ADR_CreatePremisesForLeadRecord","inProgressMessage":"In Progress","failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","extraPayload":{"isAccountActive":"%isAccountActive%","zipcode":"%zipcode%","unitNumber":"%unitNumberValue%","street":"%streetValue%","state":"%stateValue%","serviceability":"%addressInfoResponse:serviceability%","radioSelection":"%radioSelection%","phone":"%phone%","marketValue":"%marketValue%","longitude":"%addressInfoResponse:longitude%","latitude":"%addressInfoResponse:latitude%","lastName":"%lastName%","isNewLead":"%isNewLead%","firstName":"%firstName%","existingPremisesId":"%existingPremisesRecord:Id%","email":"%email%","eligibility":"%addressInfoResponse:eligibility%","city":"%cityValue%","addressId":"%addressInfoResponse:addressId%","ineligibleReason":"%addressInfoResponse:ineligibleReason%"},"errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"disOnTplt":false,"controlWidth":12,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"CreatePremisesAndLeadRecord","level":0,"indexInParent":5,"bHasAttachment":false,"bEmbed":false,"bIntegrationProcedureAction":true,"JSONPath":"CreatePremisesAndLeadRecord","lwcId":"lwc5"},{"type":"Integration Procedure Action","propSetMap":{"wpm":false,"validationRequired":"Step","useContinuation":false,"svgSprite":"","svgIcon":"","ssm":false,"showPersistentComponent":[false,false],"show":{"group":{"rules":[{"field":"radioSelection","data":"SuspectServiceable","condition":"="}],"operator":"AND"}},"sendJSONPath":"","sendJSONNode":"","responseJSONPath":"","responseJSONNode":"","remoteTimeout":30000,"remoteOptions":{"useFuture":false,"preTransformBundle":null,"postTransformBundle":"","chainable":false},"redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"preTransformBundle":"","postTransformBundle":"","postMessage":"Done","message":{},"label":"ADR_AddressReviewTicket","integrationProcedureKey":"LDM_AddressReview","inProgressMessage":"In Progress","failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","extraPayload":{"zipcode":"%zipcode%","type":"ADDRESS_REVIEW","title":"%title%","ticketCode":"CRT-ADDR","ticketCategory":"ADDRESS_RELATED","suppressEmail":true,"name":"CRT-ADDR_Preprod","market":"%marketValueTicket%","hutId":"Test Hut ID","commentText":"Review Address","author":"%userEmail%","assignee":"fiber-address-escalations@google.com","addressType":"SFU","unitNumber":"%unitNumberValue%","street":"%streetValue%","state":"%stateValue%","city":"%cityValue%"},"errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"disOnTplt":false,"controlWidth":12,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"AddressReviewTicket","level":0,"indexInParent":6,"bHasAttachment":false,"bEmbed":false,"bIntegrationProcedureAction":true,"JSONPath":"AddressReviewTicket","lwcId":"lwc6"},{"type":"DataRaptor Post Action","propSetMap":{"wpm":false,"validationRequired":"Submit","ssm":false,"showPersistentComponent":[false,false],"show":{"group":{"rules":[{"field":"radioSelection","data":"SuspectServiceable","condition":"="}],"operator":"AND"}},"sendJSONPath":"","sendJSONNode":"","remoteTimeout":30000,"redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"postTransformBundle":"","postMessage":"Done","message":{},"label":"Ticket Creation","inProgressMessage":"In Progress","failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"disOnTplt":false,"controlWidth":12,"bundle":"LDM_CreateTicketForAddressReview","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"ticketCreation","level":0,"indexInParent":7,"bHasAttachment":false,"bEmbed":false,"bDataRaptorPostAction":true,"JSONPath":"ticketCreation","lwcId":"lwc7"},{"type":"Navigate Action","propSetMap":{"wpm":false,"variant":"brand","validationRequired":"none","targetType":"Record","targetName":"lead","targetLWCLayout":"lightning","targetId":"%leadId%","targetFilter":"Recent","ssm":false,"show":null,"replace":true,"recordAction":"view","pubsub":false,"objectAction":"home","message":{},"loginAction":"login","label":"Lead Record Navigate","iconVariant":"","iconPosition":"left","iconName":"","disOnTplt":false,"controlWidth":12,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"LeadRecordNavigate","level":0,"indexInParent":8,"bHasAttachment":false,"bEmbed":false,"bNavigate":true,"JSONPath":"LeadRecordNavigate","lwcId":"lwc8"}],"bReusable":false,"bpVersion":10,"bpType":"ADR","bpSubType":"CustomerSearch","bpLang":"English","bHasAttachment":false,"lwcVarMap":{"userProfile":null,"isTechnician":null,"historyEventId":null}};