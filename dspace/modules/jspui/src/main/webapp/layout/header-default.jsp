<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%@page import="org.dspace.content.Item"%>
<%--
  - HTML header for main home page
  --%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ page import="java.util.List"%>
<%@ page import="java.util.Enumeration"%>
<%@ page import="org.dspace.app.webui.util.JSPManager" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.app.util.Util" %>
<%@ page import="javax.servlet.jsp.jstl.core.*" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.*" %>

<%
    String title = (String) request.getAttribute("dspace.layout.title");
    String navbar = (String) request.getAttribute("dspace.layout.navbar");
    boolean locbar = ((Boolean) request.getAttribute("dspace.layout.locbar")).booleanValue();

    String siteName = ConfigurationManager.getProperty("dspace.name");
    String feedRef = (String)request.getAttribute("dspace.layout.feedref");
    boolean osLink = ConfigurationManager.getBooleanProperty("websvc.opensearch.autolink");
    String osCtx = ConfigurationManager.getProperty("websvc.opensearch.svccontext");
    String osName = ConfigurationManager.getProperty("websvc.opensearch.shortname");
    List parts = (List)request.getAttribute("dspace.layout.linkparts");
    String extraHeadData = (String)request.getAttribute("dspace.layout.head");
    String extraHeadDataLast = (String)request.getAttribute("dspace.layout.head.last");
    String dsVersion = Util.getSourceVersion();
    String generator = dsVersion == null ? "DSpace" : "DSpace "+dsVersion;
    String analyticsKey = ConfigurationManager.getProperty("jspui.google.analytics.key");
    
    // Get the handle if the display page is an item
    Item item = (Item) request.getAttribute("item");
%>

<!DOCTYPE html>
<html>
    <head>
        <title><%= title %> - <%= siteName %></title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta http-equiv="X-UA-Compatible" content="IE=Edge,chrome=1" />
        <meta name="Generator" content="<%= generator %>" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        
<%
        if (extraHeadData != null){ 
%>
        <%= extraHeadData %>
<%
        }
%>
        
        <!-- Damanzano: Add Open graph metatags in order to optimize facebook sharing -->
        <meta property="og:title" content="<%= title %> - <%= siteName %>" />
        <% if(item != null){ %>
        <meta property="og:url" content="<%= request.getContextPath() %>/handle/<%= item.getHandle()%>" />
        <% } %>
        
        <link rel="shortcut icon" href="<%= request.getContextPath() %>/favicon.ico" type="image/x-icon"/>
        <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/jquery-ui-1.10.3.custom/ui-lightness/jquery-ui-1.10.3.custom.css" type="text/css" />
        <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/bootstrap/bootstrap.min.css" type="text/css" />
        <!--<link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/bootstrap/bootstrap-theme.min.css" type="text/css" />-->
        <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/bootstrap/dspace-theme.css" type="text/css" />
        <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/bootstrap/icesi-theme.min.css">

        <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
        <!--[if lt IE 9]>
        <script src="<%= request.getContextPath() %>/static/js/html5shiv.js"></script>
        <script src="<%= request.getContextPath() %>/static/js/respond.min.js"></script>
        <![endif]-->
<%
    if (!"NONE".equals(feedRef))
    {
        for (int i = 0; i < parts.size(); i+= 3)
        {
%>
        <link rel="alternate" type="application/<%= (String)parts.get(i) %>" title="<%= (String)parts.get(i+1) %>" href="<%= request.getContextPath() %>/feed/<%= (String)parts.get(i+2) %>/<%= feedRef %>"/>
<%
        }
    }
    
    if (osLink)
    {
%>
        <link rel="search" type="application/opensearchdescription+xml" href="<%= request.getContextPath() %>/<%= osCtx %>description.xml" title="<%= osName %>"/>
<%
    }
%>

    <!-- All scripts were sent to the end of body -->    
    <script src="<%= request.getContextPath() %>/static/js/modernizr/modernizr-2.6.2.min.js"></script>    

    <%--Gooogle Analytics recording.--%>
    <%
    if (analyticsKey != null && analyticsKey.length() > 0)
    {
    %>
        <script type="text/javascript">
            var _gaq = _gaq || [];
            _gaq.push(['_setAccount', '<%= analyticsKey %>']);
            _gaq.push(['_trackPageview']);

            (function() {
                var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
                ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
                var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
            })();
        </script>
    <%
    }
    %>
    <!-- damanzano:
        Printing of dspace.layout.head.las was sent to footer-default in order 
        to have all scripts at the end of the page and avoid script dependency errors
    -->
    
    </head>

    <%-- HACK: leftmargin, topmargin: for non-CSS compliant Microsoft IE browser --%>
    <%-- HACK: marginwidth, marginheight: for non-CSS compliant Netscape browser --%>
    <body class="undernavigation">
        <div class="wave">
<a class="sr-only" href="#content">Skip navigation</a>
<header class="navbar navbar-default">    
    <%
    if (!navbar.equals("off"))
    {
%>
            <div class="container">
                <dspace:include page="<%= navbar %>" />
            </div>
<%
    }
    else
    {
    	%>
        <div class="container">
            <dspace:include page="/layout/navbar-minimal.jsp" />
        </div>
<%    	
    }
%>
</header>

<%-- Main Block --%>
<main id="content" role="main">
    <!--
    <div class="container banner">
            <div class="row">
                    <div class="col-md-9 brand">
                    <h1><fmt:message key="jsp.layout.header-default.brand.heading" /></h1>
            <fmt:message key="jsp.layout.header-default.brand.description" /> 
            </div>
            <div class="col-md-3"><img class="pull-right" src="<%= request.getContextPath() %>/image/logo.gif">
            </div>
            </div>
    </div>
    -->
                <%-- Location bar --%>
<%
    if (locbar)
    {
%>
<div class="container-fluid">
                <dspace:include page="/layout/location-bar.jsp" />
</div>                
<%
    }
%>


        <%-- Page contents --%>
<div class="container-fluid">
<% if (request.getAttribute("dspace.layout.sidebar") != null) { %>
	<div class="row row-offcanvas row-offcanvas-right">
        <!--<div class="row">-->
            <div class="col-md-9 col-sm-9 col-xs-12">
<% } %>		