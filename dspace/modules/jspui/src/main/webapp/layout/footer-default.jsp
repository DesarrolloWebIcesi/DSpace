<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Footer for home page
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ page import="java.net.URLEncoder" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>

<%
    String sidebar = (String) request.getAttribute("dspace.layout.sidebar");
%>

<%-- Right-hand side bar if appropriate --%>
<%
    if (sidebar != null) {
%>
                </div>
                <div class="col-md-3">
                    <%= sidebar%>
                </div>
            </div>       
<%
    }
%>
            </div>
        </main>
        <%-- Page footer --%>
        <footer class="navbar navbar-inverse navbar-bottom">
            <div id="designedby" class="container text-muted">
                <fmt:message key="jsp.layout.footer-default.theme-by"/> <a href="http://www.cineca.it"><img
                        src="<%= request.getContextPath()%>/image/logo-cineca-small.png"
                        alt="Logo CINECA" /></a>
                <div id="footer_feedback" class="pull-right">                                    
                    <p class="text-muted"><fmt:message key="jsp.layout.footer-default.text"/>&nbsp;-
                        <a target="_blank" href="<%= request.getContextPath()%>/feedback"><fmt:message key="jsp.layout.footer-default.feedback"/></a>
                        <a href="<%= request.getContextPath()%>/htmlmap"></a></p>
                </div>
            </div>
        </footer>
                
        <!-- updated version of jquery -->
        <!-- uncomment for production enviroment -->
        <!--<script src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>-->
        <!--<script>window.jQuery || document.write("&lt;script src='<%= request.getContextPath() %>/static/js/jquery/jquery-1.10.2.min.js' &gt; &lt;\/script &gt; &lt;script src='<%= request.getContextPath() %>/static/js/jquery/jquery-ui-1.10.3.custom.min' &gt; &lt;\/script&gt;");</script>-->
        
        <script type='text/javascript' src="<%= request.getContextPath()%>/static/js/jquery/jquery-1.10.2.min.js"></script>
        <script type='text/javascript' src='<%= request.getContextPath()%>/static/js/jquery/jquery-ui-1.10.3.custom.min.js'></script>
        <script type='text/javascript' src='<%= request.getContextPath()%>/static/js/bootstrap/bootstrap.min.js'></script>
        <script type='text/javascript' src='<%= request.getContextPath()%>/static/js/holder.js'></script>
        <script type="text/javascript" src="<%= request.getContextPath()%>/utils.js"></script>
        <script type="text/javascript" src="<%= request.getContextPath()%>/static/js/choice-support.js"></script>
        
        <!-- Custom scripsts -->
        <script src="<%= request.getContextPath() %>/static/js/app.js"></script>
    </body>
</html>