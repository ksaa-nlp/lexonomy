var Thes={};
Thes.change=function(){};

Thes.render=function(div, json){
  $(div).append("<div id='pagebody' class='notop'><div class='pillarform'></div></div>"); var $div=$(div).find("div.pillarform");
  var elements=Xematron.listElements(xema);

  var $block=$("<div class='block container'></div>").appendTo($div);
	$block.append("<div i18n class='title'>Thesaurus item container</div>");
  $block.append("<select></select>");
  $block.find("select").append("<option value=''>(not set)</option>");
  for(var i=0; i<elements.length; i++){
    $block.find("select").append("<option "+(json.container==elements[i] ? "selected='selected'" : "")+" value='"+elements[i]+"'>"+elements[i]+"</option>");
  }
  $block.find("select").on("change", function(e){Thes.containerChanged(); Thes.change();});
  $block.append("<div i18n class='instro'>Select the element which should wrap each individual thesaurus item (a word). When you pull thesaurus items automatically from a corpus, Lexonomy will insert one of these elements for each thesaurus item.</div>");

  var $block=$("<div class='block template'></div>").appendTo($div);
	$block.append("<div i18n class='title'>XML template</div>");
  $block.append("<textarea class='textbox' spellcheck='false'></textarea>");
  $block.find("textarea").val(json.template).data("origval", json.template).on("change keyup", function(e){
    if($div.find(".block.template textarea").val()!=$div.find(".block.template textarea").data("origval")) Thes.change();
    Thes.validateTemplate();
  });
  $block.append("<div i18n class='instro'>This is the XML that will be inserted into your entries with each thesaurus item. The actual text will be where the placeholder <code>$text</code> is.</div>");
  $block.append("<div class='error' style='display: none;'></div>");
  Thes.validateTemplate();
};
Thes.harvest=function(div){
  var ret={};
  ret.container=$(".pillarform .block.container select").val();
  ret.template=$(".pillarform .block.template textarea").val();
  return ret;
};

Thes.validateTemplate=function(){
  var container=$(".pillarform .block.container select").val();
  var template=$.trim($(".pillarform .block.template textarea").val());
  if(container && template) {
    try{
      var xml=$.parseXML(template);
      $(".pillarform .block.template .error").hide();
      if(container && xml.documentElement.localName!=container) {
          $(".pillarform .block.template .error").html("The top-level element should be <code>"+container+"</code>.").show();
      } else {
        if(!/\$text/.test(template)) {
          $(".pillarform .block.template .error").html("The <code>$text</code> symbol is missing.").show();
        }
      }
    }catch(ex){
      $(".pillarform .block.template .error").html("The XML is invalid.").show();
    }
  }
};

Thes.containerChanged=function(){
  var container=$(".pillarform .block.container select").val();
  var template=$.trim($(".pillarform .block.template textarea").val());
  if(!template && container) {
    $(".pillarform .block.template textarea").val(Thes.composeTemplate(container));
  } else {
    try{
      var xml=$.parseXML(template);
    }catch(ex){}
    if(container && (xml.documentElement.localName!=container)){
      $(".pillarform .block.template textarea").val(Thes.composeTemplate(container));
    }
  }
  Thes.validateTemplate();
};

Thes.composeTemplate=function(topElement){
  var xml=$.parseXML(Xematron.initialElement(xema, topElement));
  var els=xml.getElementsByTagName("*");
  for(var i=0; i<els.length; i++){
    var el=els[i];
    if(xema.elements[el.localName].filling=="txt" || xema.elements[el.localName].filling=="inl") {
      el.innerHTML="$text";
      break;
    }
  }
  return xml.documentElement.outerHTML;
};
