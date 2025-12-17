<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="DAO.CategoriaDAO,DTO.CategoriaDTO,java.util.*" %>

<%
request.setAttribute("rolesPermitidos", "Administrador,Vendedor");
%>
<%@ include file="../Auth/validarAcceso.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    CategoriaDAO cdao = new CategoriaDAO();

    String accion  = request.getParameter("accion");
    String mensaje = "";
    String toastColor = "#dc3545";

    // ======================
    // ACCIONES CRUD
    // ======================
    if ("guardar".equals(accion)) {

        CategoriaDTO c = new CategoriaDTO();
        c.setNombreCategoria(request.getParameter("nombreCategoria"));
        c.setDescripcion(request.getParameter("descripcion"));

        boolean ok = cdao.registrar(c);
        mensaje    = ok ? "Categoria registrada correctamente" : "Error registrando categoria";
        toastColor = ok ? "#0dcaf0" : "#dc3545";

    } else if ("editar".equals(accion)) {

        CategoriaDTO c = new CategoriaDTO();
        c.setIdCategoria(Integer.parseInt(request.getParameter("idCategoria")));
        c.setNombreCategoria(request.getParameter("nombreCategoria"));
        c.setDescripcion(request.getParameter("descripcion"));

        boolean ok = cdao.editar(c);
        mensaje    = ok ? "Categoria actualizada correctamente" : "Error actualizando categoria";
        toastColor = ok ? "#ffc107" : "#dc3545";

    } else if ("eliminar".equals(accion)) {

        int id = Integer.parseInt(request.getParameter("idCategoria"));

        if (!cdao.tieneProductos(id)) {
            boolean ok = cdao.eliminar(id);
            mensaje    = ok ? "Categoria eliminada correctamente" : "Error eliminando categoria";
        } else {
            mensaje    = "No se puede eliminar una categoria que tiene productos";
        }
        toastColor = "#dc3545";
    }

    // ======================
    // LISTAR CATEGORÍAS
    // ======================
    String buscar = request.getParameter("buscar");
    if (buscar == null) buscar = "";

    List<CategoriaDTO> categorias = cdao.listar(buscar);
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestion de Categorias - Corporacion Carrasco</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/sidebar.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        .main-content { margin-left: 260px; padding: 25px; }

        /* ====================== TOAST ====================== */
        .toast-container { position: fixed; bottom: 20px; left: 20px; z-index: 3000; }
        .toast-custom { color:white; padding:14px 22px; border-radius:25px; 
            font-size:15px; display:flex; align-items:center; gap:15px;
            box-shadow:0 4px 10px rgba(0,0,0,0.25); transition:opacity .4s ease; }
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
        .toast-close-btn:hover { background:rgba(255,255,255,0.40); }

        /* ====================== TABLA PREMIUM ====================== */

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

        /* BOTONES DE ACCIÓN PREMIUM */
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

    </style>
</head>
<body>

<%@ include file="../Layouts/sidebar.jsp" %>

<div class="main-content">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <div style="text-transform:uppercase; font-size:12px; color:#777;">Categorias</div>
            <h3 class="fw-bold">Gestion de Categorias</h3>
            <small class="text-muted">Organiza las familias de productos</small>
        </div>

        <button class="btn btn-success px-4" data-bs-toggle="modal" data-bs-target="#modalNuevo">
            + Nueva categoria
        </button>
    </div>

    <% if (!mensaje.equals("")) { %>
        <div class="toast-container" id="toastContainer">
            <div class="toast-custom" id="toastMsg" style="background:<%=toastColor%>;">
                <span><%=mensaje%></span>
                <button class="toast-close-btn" id="toastCloseBtn">&times;</button>
            </div>
        </div>
    <% } %>

    <!-- BUSCADOR -->
    <form method="get" class="row g-2 mb-4">
        <div class="col-md-10">
            <input type="text" name="buscar" class="form-control form-control-lg"
                   placeholder="Buscar categoria..." value="<%= buscar %>">
        </div>
        <div class="col-md-2 d-grid">
            <button class="btn btn-primary btn-lg">Buscar</button>
        </div>
    </form>

    <!-- TABLA PREMIUM -->
    <div class="table-responsive">
        <table class="table-premium align-middle">
            <thead>
            <tr>
                <th style="width:60px;">#</th>
                <th>Categoria</th>
                <th>Descripcion</th>
                <th style="width:150px;">Acciones</th>
            </tr>
            </thead>

            <tbody>
            <%
                int i = 1;
                for (CategoriaDTO c : categorias) {
            %>
            <tr>
                <td><%= i++ %></td>

                <td class="fw-semibold"><%= c.getNombreCategoria() %></td>

                <td><%= c.getDescripcion() %></td>

                <td class="d-flex gap-2">

                    <!-- EDITAR -->
                    <button type="button"
                            class="btn-action-premium btn-edit btn-editar"
                            data-id="<%= c.getIdCategoria() %>"
                            data-nombre="<%= c.getNombreCategoria() %>"
                            data-descripcion="<%= c.getDescripcion() %>">
                        <img src="${pageContext.request.contextPath}/resources/img/img_editar.png">
                    </button>

                    <!-- ELIMINAR -->
                    <form method="post">
                        <input type="hidden" name="accion" value="eliminar">
                        <input type="hidden" name="idCategoria" value="<%= c.getIdCategoria() %>">

                        <button class="btn-action-premium btn-delete"
                                onclick="return confirm('¿Eliminar categoria?');">
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

<!-- MODAL NUEVA CATEGORÍA -->
<div class="modal fade" id="modalNuevo" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="post">
                <input type="hidden" name="accion" value="guardar">

                <div class="modal-header">
                    <h5 class="modal-title fw-bold">Nueva categoria</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <label class="form-label">Nombre:</label>
                    <input type="text" name="nombreCategoria" class="form-control" required>

                    <label class="form-label mt-2">Descripcion:</label>
                    <textarea name="descripcion" class="form-control"></textarea>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button class="btn btn-success px-4">Guardar</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- MODAL EDITAR -->
<div class="modal fade" id="modalEditar" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="post">
                <input type="hidden" name="accion" value="editar">
                <input type="hidden" name="idCategoria" id="edit-id">

                <div class="modal-header">
                    <h5 class="modal-title fw-bold">Editar categoria</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <label class="form-label">Nombre:</label>
                    <input type="text" name="nombreCategoria" id="edit-nombre" class="form-control" required>

                    <label class="form-label mt-2">Descripcion:</label>
                    <textarea name="descripcion" id="edit-descripcion" class="form-control"></textarea>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button class="btn btn-primary px-4">Guardar cambios</button>
                </div>

            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
// Rellenar modal editar
document.querySelectorAll(".btn-editar").forEach(btn => {
    btn.addEventListener("click", () => {
        document.getElementById("edit-id").value          = btn.dataset.id;
        document.getElementById("edit-nombre").value      = btn.dataset.nombre;
        document.getElementById("edit-descripcion").value = btn.dataset.descripcion;
        new bootstrap.Modal(document.getElementById("modalEditar")).show();
    });
});

function cerrarToast() {
    const t = document.getElementById("toastMsg");
    const c = document.getElementById("toastContainer");
    if (!t) return;
    t.style.opacity = "0";
    setTimeout(() => { if (c) c.remove(); }, 400);
}

document.addEventListener("DOMContentLoaded", () => {
    const btn = document.getElementById("toastCloseBtn");
    if (btn) btn.addEventListener("click", cerrarToast);
    setTimeout(cerrarToast, 4000);
});
</script>

</body>
</html>
