<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="DAO.ProductoDAO,DAO.CategoriaDAO,DTO.ProductoDTO,DTO.CategoriaDTO,java.util.*" %>
<%
request.setAttribute("rolesPermitidos", "Administrador,Vendedor");
%>
<%@ include file="../Auth/validarAcceso.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    ProductoDAO pdao = new ProductoDAO();
    CategoriaDAO cdao = new CategoriaDAO();

    String accion  = request.getParameter("accion");
    String mensaje = "";
    String toastColor = "#dc3545";

    // FILTRO
    String filtroCategoria = request.getParameter("categoria");
    if (filtroCategoria == null) filtroCategoria = "0";

    // ==========================
    // CRUD PRODUCTOS
    // ==========================

    if ("guardarProducto".equals(accion)) {

        ProductoDTO p = new ProductoDTO();
        p.setNombreProducto(request.getParameter("nombreProducto"));
        p.setDescripcion(request.getParameter("descripcion"));
        p.setPrecioVenta(Double.parseDouble(request.getParameter("precioVenta")));
        p.setStock(Integer.parseInt(request.getParameter("stock")));
        p.setIdCategoria(Integer.parseInt(request.getParameter("idCategoria")));
        p.setEstado(Integer.parseInt(request.getParameter("estado")));

        boolean ok = pdao.registrar(p);
        mensaje    = ok ? "Producto registrado correctamente" : "Error al registrar producto";
        toastColor = ok ? "#0dcaf0" : "#dc3545"; // celeste exito
    }

    if ("editarProducto".equals(accion)) {

        ProductoDTO p = new ProductoDTO();
        p.setIdProducto(Integer.parseInt(request.getParameter("idProducto")));
        p.setNombreProducto(request.getParameter("nombreProducto"));
        p.setDescripcion(request.getParameter("descripcion"));
        p.setPrecioVenta(Double.parseDouble(request.getParameter("precioVenta")));
        p.setStock(Integer.parseInt(request.getParameter("stock")));
        p.setIdCategoria(Integer.parseInt(request.getParameter("idCategoria")));
        p.setEstado(Integer.parseInt(request.getParameter("estado")));

        boolean ok = pdao.editar(p);
        mensaje    = ok ? "Producto actualizado correctamente" : "Error actualizando producto";
        toastColor = ok ? "#ffc107" : "#dc3545"; // amarillo exito
    }

    if ("eliminarProducto".equals(accion)) {

        int id = Integer.parseInt(request.getParameter("idProducto"));

        boolean ok = pdao.eliminar(id);
        mensaje    = ok ? "Producto eliminado correctamente" : "No se puede eliminar este producto";
        toastColor = "#dc3545"; // rojo
    }

    // LISTAS
    List<CategoriaDTO> categorias = cdao.listar();
    List<ProductoDTO> productos   = pdao.listarPorCategoria(filtroCategoria);
%>

<!DOCTYPE html>
<html>
<head>
    <title>Gestion de Productos - Corporacion Carrasco</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/sidebar.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        .main-content { margin-left: 260px; padding: 25px; }

        /* ================= TOAST ================= */
        .toast-container {
            position: fixed;
            bottom: 20px;
            left: 20px;
            z-index: 3000;
        }
        .toast-custom {
            color: white;
            padding: 14px 22px;
            border-radius: 25px;
            font-size: 15px;
            display: flex;
            align-items: center;
            gap: 15px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.25);
            opacity: 1;
            transition: opacity .4s ease;
        }
        .toast-close-btn {
            background: rgba(255,255,255,0.25);
            border: none;
            color: white;
            font-size: 18px;
            width: 28px;
            height: 28px;
            border-radius: 50%;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            pointer-events: auto;
        }
        .toast-close-btn:hover {
            background: rgba(255,255,255,0.40);
        }

        /* ================= TABLA PREMIUM ================= */

        .table-premium {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0 12px;
        }

        .table-premium thead tr {
            background: rgba(13,110,253,0.15);
            backdrop-filter: blur(8px);
        }

        .table-premium thead th {
            padding: 15px;
            font-weight: 700;
            text-transform: uppercase;
            font-size: 13px;
            color: #003f9e;
            border-bottom: 2px solid #d8e2ff;
        }

        .table-premium tbody tr {
            background: #ffffff;
            box-shadow: 0 4px 18px rgba(0,0,0,0.06);
            border-radius: 12px;
            transition: transform .15s ease, box-shadow .15s ease;
        }

        .table-premium tbody tr:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 25px rgba(0,0,0,0.12);
        }

        .table-premium tbody td {
            padding: 16px 18px;
            vertical-align: middle;
            border-top: none !important;
        }

        .table-premium tbody tr td:first-child {
            border-radius: 12px 0 0 12px;
        }

        .table-premium tbody tr td:last-child {
            border-radius: 0 12px 12px 0;
        }

        /* BOTONES ACCIÓN PREMIUM */

        .btn-action-premium {
            width: 38px;
            height: 38px;
            border-radius: 10px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            transition: .2s;
        }

        .btn-action-premium:hover {
            transform: scale(1.12);
            box-shadow: 0 3px 8px rgba(0,0,0,0.18);
        }

        .btn-edit {
            background: #e6f0ff;
            border: 1px solid #bcd2ff;
        }

        .btn-edit img { width: 17px; }

        .btn-delete {
            background: #ffe6e9;
            border: 1px solid #ffc4ca;
        }

        .btn-delete img { width: 17px; }

        /* ESTADO PRODUCTO */

        .badge-estado {
            padding: 4px 10px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 600;
        }

        .estado-activo {
            background: #e5f7eb;
            color: #137333;
        }

        .estado-inactivo {
            background: #fde2e4;
            color: #b00020;
        }

        /* CHIP STOCK (A + C) */

        .chip-stock {
            padding: 4px 11px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }

        .chip-bajo {
            background: #ffe5e9;
            color: #b42318;
        }

        .chip-medio {
            background: #fff3cd;
            color: #946200;
        }

        .chip-alto {
            background: #e5f7eb;
            color: #137333;
        }

        .chip-dot {
            width: 7px;
            height: 7px;
            border-radius: 50%;
        }

        .chip-bajo  .chip-dot { background:#e11b22; }
        .chip-medio .chip-dot { background:#f6c344; }
        .chip-alto  .chip-dot { background:#21a179; }

    </style>
</head>

<body>

<%@ include file="../Layouts/sidebar.jsp" %>

<div class="main-content">

    <!-- ENCABEZADO -->
    <div class="d-flex justify-content-between align-items-center mb-3">
        <div>
            <div style="text-transform:uppercase; font-size:12px; color:#777;">Productos</div>
            <h3 class="fw-bold mb-0">Gestión de Productos</h3>
            <small class="text-muted">Administra el catálogo y el stock de tu ferretería</small>
        </div>
    </div>

    <!-- FILTRO -->
    <form method="get" class="row g-2 mb-4">
        <div class="col-md-5">
            <select name="categoria" class="form-select form-select-lg">
                <option value="0">Todas las categorías</option>
                <% for (CategoriaDTO c : categorias) { %>
                    <option value="<%=c.getIdCategoria()%>"
                            <%= (filtroCategoria.equals(c.getIdCategoria()+"") ? "selected" : "") %>>
                        <%= c.getNombreCategoria() %>
                    </option>
                <% } %>
            </select>
        </div>

        <div class="col-md-3 d-grid">
            <button class="btn btn-primary btn-lg">Filtrar</button>
        </div>

        <div class="col-md-4 d-grid">
            <button type="button" class="btn btn-success btn-lg"
                    data-bs-toggle="modal" data-bs-target="#modalNuevo">
                + Nuevo producto
            </button>
        </div>
    </form>

    <!-- TOAST -->
    <% if (!mensaje.equals("")) { %>
    <div class="toast-container" id="toastContainer">
        <div class="toast-custom" id="toastMsg" style="background:<%= toastColor %>;">
            <span><%= mensaje %></span>
            <button class="toast-close-btn" id="toastCloseBtn">&times;</button>
        </div>
    </div>
    <% } %>

    <!-- TABLA PREMIUM -->
    <div class="table-responsive">
        <table class="table-premium align-middle">
            <thead>
            <tr>
                <th style="width:60px;">#</th>
                <th>Producto</th>
                <th>Descripción</th>
                <th>Categoría</th>
                <th>Precio</th>
                <th>Stock</th>
                <th>Estado</th>
                <th style="width:150px;">Acciones</th>
            </tr>
            </thead>

            <tbody>
            <%
                int i = 1;
                for (ProductoDTO p : productos) {

                    int stock = p.getStock();
                    String chipClass;
                    String stockTexto;

                    if (stock <= 5) {
                        chipClass = "chip-stock chip-bajo";
                        stockTexto = stock + " (Bajo)";
                    } else if (stock <= 15) {
                        chipClass = "chip-stock chip-medio";
                        stockTexto = stock + " (Medio)";
                    } else {
                        chipClass = "chip-stock chip-alto";
                        stockTexto = stock + " (Alto)";
                    }
            %>
                <tr>
                    <td><%= i++ %></td>

                    <td class="fw-semibold"><%= p.getNombreProducto() %></td>

                    <td><%= p.getDescripcion() %></td>

                    <td><%= p.getNombreCategoria() %></td>

                    <td>S/ <%= String.format("%.2f", p.getPrecioVenta()) %></td>

                    <td>
                        <span class="<%= chipClass %>">
                            <span class="chip-dot"></span>
                            <%= stockTexto %>
                        </span>
                    </td>

                    <td>
                        <% if (p.getEstado() == 1) { %>
                            <span class="badge-estado estado-activo">Activo</span>
                        <% } else { %>
                            <span class="badge-estado estado-inactivo">Inactivo</span>
                        <% } %>
                    </td>

                    <td class="d-flex gap-2">

                        <!-- EDITAR -->
                        <button class="btn-action-premium btn-edit btnEditar"
                                data-id="<%=p.getIdProducto()%>"
                                data-nombre="<%=p.getNombreProducto()%>"
                                data-desc="<%=p.getDescripcion()%>"
                                data-precio="<%=p.getPrecioVenta()%>"
                                data-stock="<%=p.getStock()%>"
                                data-cat="<%=p.getIdCategoria()%>"
                                data-estado="<%=p.getEstado()%>">
                            <img src="${pageContext.request.contextPath}/resources/img/img_editar.png">
                        </button>

                        <!-- ELIMINAR -->
                        <form method="post">
                            <input type="hidden" name="accion" value="eliminarProducto">
                            <input type="hidden" name="idProducto" value="<%=p.getIdProducto()%>">
                            <button class="btn-action-premium btn-delete"
                                    onclick="return confirm('¿Eliminar producto?');">
                                <img src="${pageContext.request.contextPath}/resources/img/img_eliminar.png">
                            </button>
                        </form>

                    </td>
                </tr>
            <% } %>
            </tbody>
        </table>
    </div>

</div>

<!-- MODAL NUEVO PRODUCTO -->
<div class="modal fade" id="modalNuevo">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <form method="post">
                <input type="hidden" name="accion" value="guardarProducto">

                <div class="modal-header">
                    <h5 class="mb-0">Registrar Producto</h5>
                    <button class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body row g-3">
                    <div class="col-md-6">
                        <label class="form-label">Nombre</label>
                        <input class="form-control" name="nombreProducto" required>
                    </div>

                    <div class="col-md-6">
                        <label class="form-label">Precio</label>
                        <input class="form-control" name="precioVenta" required>
                    </div>

                    <div class="col-md-12">
                        <label class="form-label">Descripción</label>
                        <textarea class="form-control" name="descripcion"></textarea>
                    </div>

                    <div class="col-md-4">
                        <label class="form-label">Stock</label>
                        <input class="form-control" name="stock" required>
                    </div>

                    <div class="col-md-4">
                        <label class="form-label">Categoría</label>
                        <select name="idCategoria" class="form-select">
                            <% for (CategoriaDTO c : categorias) { %>
                                <option value="<%=c.getIdCategoria()%>">
                                    <%=c.getNombreCategoria()%>
                                </option>
                            <% } %>
                        </select>
                    </div>

                    <div class="col-md-4">
                        <label class="form-label">Estado</label>
                        <select name="estado" class="form-select">
                            <option value="1">Activo</option>
                            <option value="0">Inactivo</option>
                        </select>
                    </div>
                </div>

                <div class="modal-footer">
                    <button class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button class="btn btn-success">Guardar</button>
                </div>

            </form>
        </div>
    </div>
</div>

<!-- MODAL EDITAR PRODUCTO -->
<div class="modal fade" id="modalEditar">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <form method="post">
                <input type="hidden" name="accion" value="editarProducto">
                <input type="hidden" name="idProducto" id="edit-id">

                <div class="modal-header">
                    <h5 class="mb-0">Editar Producto</h5>
                    <button class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body row g-3">
                    <div class="col-md-6">
                        <label class="form-label">Nombre</label>
                        <input class="form-control" id="edit-nombre" name="nombreProducto">
                    </div>

                    <div class="col-md-6">
                        <label class="form-label">Precio</label>
                        <input class="form-control" id="edit-precio" name="precioVenta">
                    </div>

                    <div class="col-md-12">
                        <label class="form-label">Descripción</label>
                        <textarea class="form-control" id="edit-desc" name="descripcion"></textarea>
                    </div>

                    <div class="col-md-4">
                        <label class="form-label">Stock</label>
                        <input class="form-control" id="edit-stock" name="stock">
                    </div>

                    <div class="col-md-4">
                        <label class="form-label">Categoría</label>
                        <select name="idCategoria" id="edit-cat" class="form-select">
                            <% for (CategoriaDTO c : categorias) { %>
                                <option value="<%=c.getIdCategoria()%>">
                                    <%=c.getNombreCategoria()%>
                                </option>
                            <% } %>
                        </select>
                    </div>

                    <div class="col-md-4">
                        <label class="form-label">Estado</label>
                        <select name="estado" id="edit-estado" class="form-select">
                            <option value="1">Activo</option>
                            <option value="0">Inactivo</option>
                        </select>
                    </div>
                </div>

                <div class="modal-footer">
                    <button class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button class="btn btn-primary">Guardar cambios</button>
                </div>

            </form>
        </div>
    </div>
</div>

<!-- SCRIPTS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
// Modal editar
document.querySelectorAll(".btnEditar").forEach(btn => {
    btn.addEventListener("click", function () {
        document.getElementById("edit-id").value     = this.dataset.id;
        document.getElementById("edit-nombre").value = this.dataset.nombre;
        document.getElementById("edit-desc").value   = this.dataset.desc;
        document.getElementById("edit-precio").value = this.dataset.precio;
        document.getElementById("edit-stock").value  = this.dataset.stock;
        document.getElementById("edit-cat").value    = this.dataset.cat;
        document.getElementById("edit-estado").value = this.dataset.estado;

        new bootstrap.Modal(document.getElementById("modalEditar")).show();
    });
});

// TOAST
function cerrarToast() {
    const toast = document.getElementById("toastMsg");
    const cont  = document.getElementById("toastContainer");
    if (!toast) return;
    toast.style.opacity = "0";
    setTimeout(() => { if (cont) cont.remove(); }, 400);
}

document.addEventListener("DOMContentLoaded", () => {
    const btn = document.getElementById("toastCloseBtn");
    if (btn) btn.addEventListener("click", cerrarToast);
    setTimeout(cerrarToast, 4000);
});
</script>

</body>
</html>
