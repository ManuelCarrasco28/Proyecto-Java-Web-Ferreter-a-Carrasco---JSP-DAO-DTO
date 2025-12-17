<%
    String rolSidebar = (String) session.getAttribute("rol");
    String usuarioSidebar = (String) session.getAttribute("usuario");
    String nombreSidebar = (String) session.getAttribute("nombreCompleto");
    boolean esAdmin = "Administrador".equals(rolSidebar);
    boolean esVendedor = "Vendedor".equals(rolSidebar);
%>

<!-- SIDEBAR GLOBAL -->
<div class="sidebar">

    <div class="brand">
        <img src="${pageContext.request.contextPath}/resources/img/logosac.png"
             class="brand-logo">
        <span>Carrasco S.A.C.</span>
    </div>

    <div class="user-info">
        <div class="user-label">Sesion activa</div>
        <div class="user-username"><%= usuarioSidebar != null ? usuarioSidebar : "" %></div>
        <div class="user-role">Rol: <%= rolSidebar != null ? rolSidebar : "-" %></div>
    </div>

    <ul class="menu">

        <% if (esAdmin || esVendedor) { %>
        <li>
            <a href="${pageContext.request.contextPath}/APP/Dashboard/Dashboard.jsp">
                <img src="${pageContext.request.contextPath}/resources/img/img_dashboard.png" class="icon">
                <span>Dashboard</span>
            </a>
        </li>
        <% } %>

        <% if (esAdmin || esVendedor) { %>
        <li>
            <a href="${pageContext.request.contextPath}/APP/Personas/Personas.jsp">
                <img src="${pageContext.request.contextPath}/resources/img/img_clientes.png" class="icon">
                <span>Clientes</span>
            </a>
        </li>
        <% } %>

        <% if (esAdmin) { %>
        <li>
            <a href="${pageContext.request.contextPath}/APP/Compra/Proveedor.jsp">
                <img src="${pageContext.request.contextPath}/resources/img/img_proveedor.png" class="icon">
                <span>Proveedores</span>
            </a>
        </li>
        <% } %>

        <% if (esAdmin) { %>
        <li>
            <a href="${pageContext.request.contextPath}/APP/Usuarios/Usuarios.jsp">
                <img src="${pageContext.request.contextPath}/resources/img/img_usuarios.png" class="icon">
                <span>Usuarios</span>
            </a>
        </li>
        <% } %>

        <% if (esAdmin || esVendedor) { %>
        <li class="submenu">
            <a href="#" class="menu-link" id="toggleProductos">
                <div style="display:flex;align-items:center;gap:10px;">
                    <img src="${pageContext.request.contextPath}/resources/img/img_productos.png" class="icon">
                    <span>Productos</span>
                </div>

                <span class="arrow">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
                        <path d="M9 6l6 6-6 6" stroke="white" stroke-width="2"
                              stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                </span>
            </a>

            <ul class="submenu-items" id="submenuProductos">
                <li>
                    <a href="${pageContext.request.contextPath}/APP/Categorias/Categorias.jsp">
                        <img src="${pageContext.request.contextPath}/resources/img/img_categorias.png" class="icon">
                        Categorias
                    </a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/APP/Productos/Productos.jsp">
                        <img src="${pageContext.request.contextPath}/resources/img/img_produ.png" class="icon">
                        Productos
                    </a>
                </li>
            </ul>
        </li>
        <% } %>

        <% if (esAdmin || esVendedor) { %>
        <li>
            <a href="${pageContext.request.contextPath}/APP/Ventas/Ventas.jsp">
                <img src="${pageContext.request.contextPath}/resources/img/img_ventas.png" class="icon">
                <span>Ventas</span>
            </a>
        </li>
        <% } %>

        <% if (esAdmin) { %>
        <li>
            <a href="${pageContext.request.contextPath}/APP/Compra/Compra.jsp">
                <img src="${pageContext.request.contextPath}/resources/img/img_compras.png" class="icon">
                <span>Compras</span>
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/APP/Reportes/Reportes.jsp">
                <img src="${pageContext.request.contextPath}/resources/img/img_reportes.png" class="icon">
                <span>Reportes</span>
            </a>
        </li>
        <% } %>

        <li class="logout">
            <a href="${pageContext.request.contextPath}/APP/Usuarios/Usuarios_Login.jsp">
                <img src="${pageContext.request.contextPath}/resources/img/img_logout.png" class="icon">
                <span>Cerrar sesion</span>
            </a>
        </li>

    </ul>
</div>
                
<script>
document.getElementById("toggleProductos").addEventListener("click", function (e) {
    e.preventDefault();

    let submenu = document.getElementById("submenuProductos");
    let arrow = this.querySelector(".arrow");

    // alternar display
    if (submenu.style.display === "block") {
        submenu.style.display = "none";
        arrow.classList.remove("rotate");
    } else {
        submenu.style.display = "block";
        arrow.classList.add("rotate");
    }
});
</script>
