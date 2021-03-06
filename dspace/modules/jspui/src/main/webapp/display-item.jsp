<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Renders a whole HTML page for displaying item metadata.  Simply includes
  - the relevant item display component in a standard HTML page.
  -
  - Attributes:
  -    display.all - Boolean - if true, display full metadata record
  -    item        - the Item to display
  -    collections - Array of Collections this item appears in.  This must be
  -                  passed in for two reasons: 1) item.getCollections() could
  -                  fail, and we're already committed to JSP display, and
  -                  2) the item might be in the process of being submitted and
  -                  a mapping between the item and collection might not
  -                  appear yet.  If this is omitted, the item display won't
  -                  display any collections.
  -    admin_button - Boolean, show admin 'edit' button
  --%>
<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="org.dspace.content.Collection" %>
<%@ page import="org.dspace.content.DCValue" %>
<%@ page import="org.dspace.content.Community" %>
<%@ page import="org.dspace.content.Item" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.handle.HandleManager" %>
<%@ page import="org.dspace.license.CreativeCommons" %>
<%@page import="javax.servlet.jsp.jstl.fmt.LocaleSupport"%>
<%@page import="org.dspace.versioning.Version"%>
<%@page import="org.dspace.core.Context"%>
<%@page import="org.dspace.app.webui.util.VersionUtil"%>
<%@page import="org.dspace.app.webui.util.UIUtil"%>
<%@page import="org.dspace.authorize.AuthorizeManager"%>
<%@page import="java.util.List"%>
<%@page import="org.dspace.core.Constants"%>
<%@page import="org.dspace.eperson.EPerson"%>
<%@page import="org.dspace.versioning.VersionHistory"%>
<%@page import="org.elasticsearch.common.trove.strategy.HashingStrategy"%>
<%
    // Attributes
    Boolean displayAllBoolean = (Boolean) request.getAttribute("display.all");
    boolean displayAll = (displayAllBoolean != null && displayAllBoolean.booleanValue());
    Boolean suggest = (Boolean)request.getAttribute("suggest.enable");
    boolean suggestLink = (suggest == null ? false : suggest.booleanValue());
    Item item = (Item) request.getAttribute("item");
    Collection[] collections = (Collection[]) request.getAttribute("collections");
    Boolean admin_b = (Boolean)request.getAttribute("admin_button");
    boolean admin_button = (admin_b == null ? false : admin_b.booleanValue());
    
    // get the workspace id if one has been passed
    Integer workspace_id = (Integer) request.getAttribute("workspace_id");

    // get the handle if the item has one yet
    String handle = item.getHandle();

    // CC URL & RDF
    String cc_url = CreativeCommons.getLicenseURL(item);
    String cc_rdf = CreativeCommons.getLicenseRDF(item);

    // Full title needs to be put into a string to use as tag argument
    String title = "";
    if (handle == null)
 	{
		title = "Workspace Item";
	}
	else 
	{
		DCValue[] titleValue = item.getDC("title", null, Item.ANY);
		if (titleValue.length != 0)
		{
			title = titleValue[0].value;
		}
		else
		{
			title = "Item " + handle;
		}
	}
    
    Boolean versioningEnabledBool = (Boolean)request.getAttribute("versioning.enabled");
    boolean versioningEnabled = (versioningEnabledBool!=null && versioningEnabledBool.booleanValue());
    Boolean hasVersionButtonBool = (Boolean)request.getAttribute("versioning.hasversionbutton");
    Boolean hasVersionHistoryBool = (Boolean)request.getAttribute("versioning.hasversionhistory");
    boolean hasVersionButton = (hasVersionButtonBool!=null && hasVersionButtonBool.booleanValue());
    boolean hasVersionHistory = (hasVersionHistoryBool!=null && hasVersionHistoryBool.booleanValue());
    
    Boolean newversionavailableBool = (Boolean)request.getAttribute("versioning.newversionavailable");
    boolean newVersionAvailable = (newversionavailableBool!=null && newversionavailableBool.booleanValue());
    Boolean showVersionWorkflowAvailableBool = (Boolean)request.getAttribute("versioning.showversionwfavailable");
    boolean showVersionWorkflowAvailable = (showVersionWorkflowAvailableBool!=null && showVersionWorkflowAvailableBool.booleanValue());
    
    String latestVersionHandle = (String)request.getAttribute("versioning.latestversionhandle");
    String latestVersionURL = (String)request.getAttribute("versioning.latestversionurl");
    
    VersionHistory history = (VersionHistory)request.getAttribute("versioning.history");
    List<Version> historyVersions = (List<Version>)request.getAttribute("versioning.historyversions");
    
    /*  damanzano: 
        This code is used to validate if it is necesary to include departamental 
        library's logo
    */
    Community[] communities = item.getCommunities();
    boolean isPatrimonial = false;
    boolean communityFinded = false;
    if (communities != null) {
        for (int i = 0; (i < communities.length) && (communityFinded == false); i++) {
            Community theCommunity = communities[i];
            if (theCommunity.getHandle().equals("10906/5698")) {
                isPatrimonial = true;
                communityFinded = true;
            }
        }
    }
    
    /** damanzano:
     *  The dc.identifier.citation is needed to show full citation instead of handle.
     */
    String citation = "";
    if (handle != null) {
        DCValue[] citationValue = item.getDC("identifier", "citation", Item.ANY);
        if (citationValue.length != 0) {
            citation = citationValue[0].value;
        } else {
            citation = "";
        }
    }
%>

<%@page import="org.dspace.app.webui.servlet.MyDSpaceServlet"%>
<dspace:layout title="<%= title %>">
<%
    if (handle != null)
    {
%>

		<%		
		if (newVersionAvailable)
		   {
		%>
		<div class="alert alert-warning"><b><fmt:message key="jsp.version.notice.new_version_head"/></b>		
		<fmt:message key="jsp.version.notice.new_version_help"/><a href="<%=latestVersionURL %>"><%= latestVersionHandle %></a>
		</div>
		<%
		    }
		%>
		
		<%		
		if (showVersionWorkflowAvailable)
		   {
		%>
		<div class="alert alert-warning"><b><fmt:message key="jsp.version.notice.workflow_version_head"/></b>		
		<fmt:message key="jsp.version.notice.workflow_version_help"/>
		</div>
		<%
		    }
		%>
		

                <%-- <strong>Please use this identifier to cite or link to this item:
                <code><%= HandleManager.getCanonicalForm(handle) %></code></strong>--%>
                <div class="well">
                    <fmt:message key="jsp.display-item.identifier"/>
                    <p><%= citation %><fmt:message key="jsp.display-item.retrieved"/> (<%= HandleManager.getCanonicalForm(handle)%>)</p>
                    <button class="visible-xs pull-right btn btn-primary" type="button" data-toggle="offcanvas" data-target=".sidebar-section">
                    <fmt:message key="jsp.display-item.collection-actions"/> <span class="glyphicon glyphicon-arrow-right"></span>
                    </button>
                </div>
<%
    }

    String displayStyle = (displayAll ? "full" : "");

    if (isPatrimonial && !(admin_button)) 
    {
%>
    <div id="patrimonial-item text-center">
        <img class="img-responsive" src="<%= request.getContextPath()%>/image/manzanasaber.png" alt="<fmt:message key="jsp.display-item.deptlibrary-item" />" />
    </div>
<%  } %>
    <dspace:item-preview item="<%= item %>" />
    <dspace:item-video-preview item="<%= item %>" title="<%= title %>" player="jplayer"/>
    <dspace:item-soundcloud-preview item="<%= item %>" title="<%= title %>" />
    <dspace:item item="<%= item %>" collections="<%= collections %>" style="<%= displayStyle %>" />

<br/>
    <%-- Versioning table --%>
<%
    if (versioningEnabled && hasVersionHistory)
    {
        boolean item_history_view_admin = ConfigurationManager
                .getBooleanProperty("versioning", "item.history.view.admin");
        if(!item_history_view_admin || admin_button) {         
%>
	<div id="versionHistory" class="panel panel-info">
	<div class="panel-heading"><fmt:message key="jsp.version.history.head2" /></div>
	
	<table class="table panel-body">
		<tr>
			<th id="tt1" class="oddRowEvenCol"><fmt:message key="jsp.version.history.column1"/></th>
			<th 			
				id="tt2" class="oddRowOddCol"><fmt:message key="jsp.version.history.column2"/></th>
			<th 
				 id="tt3" class="oddRowEvenCol"><fmt:message key="jsp.version.history.column3"/></th>
			<th 
				
				id="tt4" class="oddRowOddCol"><fmt:message key="jsp.version.history.column4"/></th>
			<th 
				 id="tt5" class="oddRowEvenCol"><fmt:message key="jsp.version.history.column5"/> </th>
		</tr>
		
		<% for(Version versRow : historyVersions) {  
		
			EPerson versRowPerson = versRow.getEperson();
			String[] identifierPath = VersionUtil.addItemIdentifier(item, versRow);
		%>	
		<tr>			
			<td headers="tt1" class="oddRowEvenCol"><%= versRow.getVersionNumber() %></td>
			<td headers="tt2" class="oddRowOddCol"><a href="<%= request.getContextPath() + identifierPath[0] %>"><%= identifierPath[1] %></a><%= item.getID()==versRow.getItemID()?"<span class=\"glyphicon glyphicon-asterisk\"></span>":""%></td>
			<td headers="tt3" class="oddRowEvenCol"><% if(admin_button) { %><a
				href="mailto:<%= versRowPerson.getEmail() %>"><%=versRowPerson.getFullName() %></a><% } else { %><%=versRowPerson.getFullName() %><% } %></td>
			<td headers="tt4" class="oddRowOddCol"><%= versRow.getVersionDate() %></td>
			<td headers="tt5" class="oddRowEvenCol"><%= versRow.getSummary() %></td>
		</tr>
		<% } %>
	</table>
	<div class="panel-footer"><fmt:message key="jsp.version.history.legend"/></div>
	</div>
<%
        }
    }
%>
<br/>
    <%-- Creative Commons Link --%>
<%
  /* ffceballos: Por petición de biblioteca, a TODOS los items se les debe desplegar la  licencia creative commons
*/ if (cc_url != null)
    { 
%>  
    <p class="submitFormHelp alert alert-info"><fmt:message key="jsp.display-item.text3"/> <a href="<%= cc_url %>"><fmt:message key="jsp.display-item.license"/></a>
    <a href="<%= cc_url %>"><img src="<%= request.getContextPath() %>/image/cc-somerights.gif" border="0" alt="Creative Commons" style="margin-top: -5px;" class="pull-right"/></a>
    </p>
    <!--
    <%= cc_rdf %>
    -->
<%
    } else {
%>
 
    <p class="submitFormHelp alert alert-info"><fmt:message key="jsp.display-item.text3"/> <a href="http://creativecommons.org/licenses/by/4.0/"><fmt:message key="jsp.display-item.license"/></a>
    <a href="http://creativecommons.org/licenses/by/4.0/"><img src="<%= request.getContextPath() %>/image/cc-somerights.gif" border="0" alt="Creative Commons" style="margin-top: -5px;" class="pull-right"/></a>
    </p>

  <!--  <p class="submitFormHelp alert alert-info"><fmt:message key="jsp.display-item.copyright"/></p>  -->
<%
    } 
%>

    <dspace:sidebar>
<%
    if (handle != null)
    {
        if (admin_button)  // admin edit button
        { 
%>
        <div class="panel panel-warning">
            <div class="panel-heading"><fmt:message key="jsp.admintools"/></div>
            <div class="panel-body">
                <form method="get" action="<%= request.getContextPath()%>/tools/edit-item">
                    <input type="hidden" name="item_id" value="<%= item.getID()%>" />
                    <%--<input type="submit" name="submit" value="Edit...">--%>
                    <input class="btn btn-default col-md-12" type="submit" name="submit" value="<fmt:message key="jsp.general.edit.button"/>" />
                </form>
                <form method="post" action="<%= request.getContextPath()%>/mydspace">
                    <input type="hidden" name="item_id" value="<%= item.getID()%>" />
                    <input type="hidden" name="step" value="<%= MyDSpaceServlet.REQUEST_EXPORT_ARCHIVE%>" />
                    <input class="btn btn-default col-md-12" type="submit" name="submit" value="<fmt:message key="jsp.mydspace.request.export.item"/>" />
                </form>
                <form method="post" action="<%= request.getContextPath()%>/mydspace">
                    <input type="hidden" name="item_id" value="<%= item.getID()%>" />
                    <input type="hidden" name="step" value="<%= MyDSpaceServlet.REQUEST_MIGRATE_ARCHIVE%>" />
                    <input class="btn btn-default col-md-12" type="submit" name="submit" value="<fmt:message key="jsp.mydspace.request.export.migrateitem"/>" />
                </form>
                <form method="post" action="<%= request.getContextPath()%>/dspace-admin/metadataexport">
                    <input type="hidden" name="handle" value="<%= item.getHandle()%>" />
                    <input class="btn btn-default col-md-12" type="submit" name="submit" value="<fmt:message key="jsp.general.metadataexport.button"/>" />
                </form>
                <% if (hasVersionButton) {%>       
                <form method="get" action="<%= request.getContextPath()%>/tools/version">
                    <input type="hidden" name="itemID" value="<%= item.getID()%>" />                    
                    <input class="btn btn-default col-md-12" type="submit" name="submit" value="<fmt:message key="jsp.general.version.button"/>" />
                </form>
                <% } %> 
                <% if (hasVersionHistory) {%>			                
                <form method="get" action="<%= request.getContextPath()%>/tools/history">
                    <input type="hidden" name="itemID" value="<%= item.getID()%>" />
                    <input type="hidden" name="versionID" value="<%= history.getVersion(item) != null ? history.getVersion(item).getVersionId() : null%>" />                    
                    <input class="btn btn-info col-md-12" type="submit" name="submit" value="<fmt:message key="jsp.general.version.history.button"/>" />
                </form>         	         	
                <% } %>
            </div>
        </div>
<%
        }
    } 
%>
        <div class="panel panel-warning">
            <div class="panel-heading"><fmt:message key="jsp.display-item.actions"/></div>
            <div class="panel-body">
            <%
            String locationLink = request.getContextPath() + "/handle/" + handle;

            if (displayAll)
            {
            
                if (workspace_id != null)
                {
            %>
                <form class="col-md-2" method="post" action="<%= request.getContextPath() %>/view-workspaceitem">
                    <input type="hidden" name="workspace_id" value="<%= workspace_id.intValue() %>" />
                    <input class="col-md-12 col-sm-12 col-xs-12 btn btn-default" type="submit" name="submit_simple" value="<fmt:message key="jsp.display-item.text1"/>" />
                </form>
            <%
                }
                else
                {
            %>
                <a class="col-md-12 col-sm-12 col-xs-12 btn btn-default" href="<%=locationLink %>?mode=simple">
                    <fmt:message key="jsp.display-item.text1"/>
                </a>
            <%
                }
        
            }
            else
            {
                if (workspace_id != null)
                {
            %>
                <form class="col-md-2" method="post" action="<%= request.getContextPath() %>/view-workspaceitem">
                    <input type="hidden" name="workspace_id" value="<%= workspace_id.intValue() %>" />
                    <input class="col-md-12 col-sm-12 col-xs-12 btn btn-default" type="submit" name="submit_full" value="<fmt:message key="jsp.display-item.text2"/>" />
                </form>
            <%
                }
                else
                {
            %>
                <a class="col-md-12 col-sm-12 col-xs-12 btn btn-default" href="<%=locationLink %>?mode=full">
                    <fmt:message key="jsp.display-item.text2"/>
                </a>
            <%
                }
            }

            if (workspace_id != null)
            {
            %>
                <form class="col-md-2" method="post" action="<%= request.getContextPath() %>/workspace">
                     <input type="hidden" name="workspace_id" value="<%= workspace_id.intValue() %>"/>
                     <input class="col-md-12 col-sm-12 col-xs-12 btn btn-primary" type="submit" name="submit_open" value="<fmt:message key="jsp.display-item.back_to_workspace"/>"/>
                </form>
            <%
            } else {
                if (suggestLink)
                {
            %>
                <a class="col-md-12 col-sm-12 col-xs-12 btn btn-success" href="<%= request.getContextPath() %>/suggest?handle=<%= handle %>" target="new_window">
                    <fmt:message key="jsp.display-item.suggest"/>
                </a>
            <%
                }
            %>
                <a class="statisticsLink  col-md-12 col-sm-12 col-xs-12 btn btn-primary" href="<%= request.getContextPath() %>/handle/<%= handle %>/statistics">
                    <fmt:message key="jsp.display-item.display-statistics"/> <span class="icesiicon icesiicon-statistics"></span>
                </a>

            <%-- SFX Link --%>
            <%
                if (ConfigurationManager.getProperty("sfx.server.url") != null)
                {
                    String sfximage = ConfigurationManager.getProperty("sfx.server.image_url");
                    if (sfximage == null)
                    {
                        sfximage = request.getContextPath() + "/image/sfx-link.gif";
                    }
            %>
                <a class="btn btn-default col-md-12 col-sm-12 col-xs-12" href="<dspace:sfxlink item="<%= item %>"/>" /><img src="<%= sfximage %>" border="0" alt="SFX Query" /></a>
            <%
                }
            }
            %>
            </div>
        </div>
            
        <div class="panel panel-warning">
            <div class="panel-heading"><fmt:message key="jsp.display-item.export"/> </div>
            <div class="panel-body">
                <dspace:item-bibliography item="<%= item %>"/>
            </div>
        </div>
    </dspace:sidebar>
</dspace:layout>
