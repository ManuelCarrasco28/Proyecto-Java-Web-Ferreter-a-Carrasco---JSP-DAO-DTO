<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="DAO.UsuarioDAO,DTO.UsuarioDTO,java.util.*" %>
<%
request.setAttribute("rolesPermitidos", "Administrador");
%>
<%@ include file="../Auth/validarAcceso.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    UsuarioDAO udao = new UsuarioDAO();

    String accion     = request.getParameter("accion");
    String mensaje    = "";
    String toastColor = "#dc3545";

    // ==========================
    // ACCIONES CRUD
    // ==========================
    if ("registrar".equals(accion)) {

        String nombres   = request.getParameter("nombres");
        String apellidos = request.getParameter("apellidos");
        String dni       = request.getParameter("dni");
        String telefono  = request.getParameter("telefono");

        boolean datosValidos =
            nombres != null && nombres.matches("[A-Za-z ]+") &&
            apellidos != null && apellidos.matches("[A-Za-z ]+") &&
            dni != null && dni.matches("[0-9]{8}") &&
            (telefono == null || telefono.isEmpty() || telefono.matches("[0-9]{9}"));

        UsuarioDTO u = new UsuarioDTO();
        u.setNombres(nombres);
        u.setApellidos(apellidos);
        u.setDni(dni);
        u.setTelefono(telefono);
        u.setCorreo(request.getParameter("correo"));
        u.setDireccion(request.getParameter("direccion"));
        u.setUsuario(request.getParameter("usuario"));
        u.setContrasena(request.getParameter("contrasena"));
        u.setRol(request.getParameter("rol"));
        u.setEstado(Integer.parseInt(request.getParameter("estado")));

        if (datosValidos) {
            boolean ok = udao.registrar(u);
            mensaje    = ok ? "Usuario registrado correctamente" : "Error registrando usuario";
            toastColor = ok ? "#0dcaf0" : "#dc3545"; // celeste exito
        } else {
            mensaje    = "Datos inválidos: verifique nombres, apellidos, DNI (8 dígitos) y teléfono (9 dígitos)";
            toastColor = "#dc3545";
        }

    } else if ("actualizar".equals(accion)) {

        String nombres   = request.getParameter("nombres");
        String apellidos = request.getParameter("apellidos");
        String dni       = request.getParameter("dni");
        String telefono  = request.getParameter("telefono");

        boolean datosValidos =
            nombres != null && nombres.matches("[A-Za-z ]+") &&
            apellidos != null && apellidos.matches("[A-Za-z ]+") &&
            dni != null && dni.matches("[0-9]{8}") &&
            (telefono == null || telefono.isEmpty() || telefono.matches("[0-9]{9}"));

        UsuarioDTO u = new UsuarioDTO();

        u.setIdUsuario(Integer.parseInt(request.getParameter("idUsuario")));
        u.setIdPersona(Integer.parseInt(request.getParameter("idPersona")));
        u.setNombres(nombres);
        u.setApellidos(apellidos);
        u.setDni(dni);
        u.setTelefono(telefono);
        u.setCorreo(request.getParameter("correo"));
        u.setDireccion(request.getParameter("direccion"));
        u.setUsuario(request.getParameter("usuario"));
        u.setContrasena(request.getParameter("contrasena"));
        u.setRol(request.getParameter("rol"));
        u.setEstado(Integer.parseInt(request.getParameter("estado")));

        if (datosValidos) {
            boolean ok = udao.actualizar(u);
            mensaje    = ok ? "Usuario actualizado correctamente" : "Error actualizando usuario";
            toastColor = ok ? "#ffc107" : "#dc3545"; // amarillo exito
        } else {
            mensaje    = "Datos inválidos: verifique nombres, apellidos, DNI (8 dígitos) y teléfono (9 dígitos)";
            toastColor = "#dc3545";
        }

    } else if ("eliminar".equals(accion)) {

        int idUsuario = Integer.parseInt(request.getParameter("idUsuario"));
        int idPersona = Integer.parseInt(request.getParameter("idPersona"));

        boolean ok = udao.eliminar(idUsuario, idPersona);
        mensaje    = ok ? "Usuario eliminado correctamente" : "Error eliminando usuario";
        toastColor = "#dc3545";
    }

    // ==========================
    // LISTADO
    // ==========================
    List<UsuarioDTO> usuarios = udao.listar();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestión de Usuarios - Corporación Carrasco</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/sidebar.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            background: #f5f7fb;
        }

        .main-content {
            margin-left: 260px;
            padding: 22px 26px;
        }

        .page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 16px;
        }

        .eyebrow {
            text-transform: uppercase;
            letter-spacing: .35px;
            font-size: 12px;
            color: #6b7280;
            margin-bottom: 3px;
        }

        .page-title {
            margin: 0;
            font-size: 24px;
            font-weight: 700;
            color: #111827;
        }

        .subtitle {
            margin: 2px 0 0;
            color: #6b7280;
            font-size: 13px;
        }

        .card-panel {
            background: #ffffff;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(15, 23, 42, 0.12);
            padding: 18px 20px 22px;
        }

        .icon-btn {
            width: 20px;
        }

        .badge-estado-activo {
            background: #16a34a;
        }

        .badge-estado-inactivo {
            background: #dc2626;
        }

        /* Tabla estilo moderno */
        .table-modern thead {
            background: #0d6efd;
            color: #fff;
        }

        .table-modern th,
        .table-modern td {
            vertical-align: middle;
            font-size: 14px;
        }

        .table-modern tbody tr:hover {
            background: #f1f5ff;
        }

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
    </style>
</head>
<body>

<%@ include file="../Layouts/sidebar.jsp" %>

<div class="main-content">

    <!-- ENCABEZADO -->
    <div class="page-header">
        <div>
            <div class="eyebrow">Usuarios</div>
            <h2 class="page-title">Gestión de Usuarios</h2>
            <p class="subtitle">Administra las cuentas, roles y estados de acceso al sistema</p>
        </div>
        <button class="btn btn-success" data-bs-toggle="modal" data-bs-target="#modalNuevo">
            + Nuevo usuario
        </button>
    </div>

    <!-- TOAST -->
    <% if (!mensaje.equals("")) { %>
    <div class="toast-container" id="toastContainer">
        <div class="toast-custom" id="toastMsg" style="background:<%= toastColor %>;">
            <span><%= mensaje %></span>
            <button class="toast-close-btn" id="toastCloseBtn">&times;</button>
        </div>
    </div>
    <% } %>

    <!-- CONTENEDOR PRINCIPAL -->
    <div class="card-panel">

        <div class="d-flex justify-content-between align-items-center mb-3">
            <h6 class="mb-0 text-muted">Listado de usuarios registrados</h6>
            <!-- Botón ya está en el header principal, aquí no añadimos otro -->
        </div>

        <!-- TABLA -->
        <div class="table-responsive">
            <table class="table table-modern align-middle">
                <thead>
                <tr>
                    <th>#</th>
                    <th>Nombres</th>
                    <th>Apellidos</th>
                    <th>DNI</th>
                    <th>Teléfono</th>
                    <th>Correo</th>
                    <th>Dirección</th>
                    <th>Usuario</th>
                    <th>Rol</th>
                    <th>Estado</th>
                    <th style="width: 120px;">Acciones</th>
                </tr>
                </thead>
                <tbody>
                <%
                    int i = 1;
                    for (UsuarioDTO u : usuarios) {
                %>
                <tr>
                    <td><%= i++ %></td>
                    <td><%= u.getNombres() %></td>
                    <td><%= u.getApellidos() %></td>
                    <td><%= u.getDni() %></td>
                    <td><%= u.getTelefono() %></td>
                    <td><%= u.getCorreo() %></td>
                    <td><%= u.getDireccion() %></td>
                    <td><%= u.getUsuario() %></td>
                    <td><%= u.getRol() %></td>
                    <td>
                        <% if (u.getEstado() == 1) { %>
                            <span class="badge badge-estado-activo">Activo</span>
                        <% } else { %>
                            <span class="badge badge-estado-inactivo">Inactivo</span>
                        <% } %>
                    </td>
                    <td>
                        <!-- EDITAR -->
                        <button type="button"
                                class="btn btn-sm btn-outline-primary btn-editar"
                                data-idUsuario="<%= u.getIdUsuario() %>"
                                data-idPersona="<%= u.getIdPersona() %>"
                                data-nombres="<%= u.getNombres() %>"
                                data-apellidos="<%= u.getApellidos() %>"
                                data-dni="<%= u.getDni() %>"
                                data-telefono="<%= u.getTelefono() %>"
                                data-correo="<%= u.getCorreo() %>"
                                data-direccion="<%= u.getDireccion() %>"
                                data-usuario="<%= u.getUsuario() %>"
                                data-rol="<%= u.getRol() %>"
                                data-estado="<%= u.getEstado() %>">
                            <img src="${pageContext.request.contextPath}/resources/img/img_editar.png"
                                 class="icon-btn" alt="Editar">
                        </button>

                        <!-- ELIMINAR -->
                        <form method="post" style="display:inline;">
                            <input type="hidden" name="accion" value="eliminar">
                            <input type="hidden" name="idUsuario" value="<%= u.getIdUsuario() %>">
                            <input type="hidden" name="idPersona" value="<%= u.getIdPersona() %>">
                            <button class="btn btn-sm btn-outline-danger"
                                    onclick="return confirm('¿Eliminar usuario?');">
                                <img src="${pageContext.request.contextPath}/resources/img/img_eliminar.png"
                                     class="icon-btn" alt="Eliminar">
                            </button>
                        </form>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>

    </div> <!-- /card-panel -->

</div> <!-- /main-content -->

<!-- MODAL NUEVO -->
<div class="modal fade" id="modalNuevo">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">

            <form method="post">
                <input type="hidden" name="accion" value="registrar">

                <div class="modal-header">
                    <h5 class="modal-title">Nuevo usuario</h5>
                    <button class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body row g-3">

                    <div class="col-md-6">
                        <label>Nombres</label>
                        <input type="text" name="nombres" class="form-control" required
                               pattern="[A-Za-z ]+" title="Solo letras y espacios">
                    </div>

                    <div class="col-md-6">
                        <label>Apellidos</label>
                        <input type="text" name="apellidos" class="form-control" required
                               pattern="[A-Za-z ]+" title="Solo letras y espacios">
                    </div>

                    <div class="col-md-4">
                        <label>DNI</label>
                        <input type="text" name="dni" class="form-control" required
                               maxlength="8" pattern="[0-9]{8}" title="8 digitos numericos">
                    </div>

                    <div class="col-md-4">
                        <label>Teléfono</label>
                        <input type="text" name="telefono" class="form-control"
                               maxlength="9" pattern="[0-9]{9}" title="9 digitos numericos">
                    </div>

                    <div class="col-md-4">
                        <label>Correo</label>
                        <input type="email" name="correo" class="form-control">
                    </div>

                    <div class="col-md-12">
                        <label>Dirección</label>
                        <input type="text" name="direccion" class="form-control">
                    </div>

                    <hr>

                    <div class="col-md-6">
                        <label>Usuario</label>
                        <input type="text" name="usuario" class="form-control" required>
                    </div>

                    <div class="col-md-6">
                        <label>Contraseña</label>
                        <input type="password" name="contrasena" class="form-control" required>
                    </div>

                    <div class="col-md-6">
                        <label>Rol</label>
                        <select name="rol" class="form-select">
                            <option value="Administrador">Administrador</option>
                            <option value="Vendedor">Vendedor</option>
                        </select>
                    </div>

                    <div class="col-md-6">
                        <label>Estado</label>
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

<!-- MODAL EDITAR -->
<div class="modal fade" id="modalEditar">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">

            <form method="post">
                <input type="hidden" name="accion" value="actualizar">

                <input type="hidden" name="idUsuario" id="edit-idUsuario">
                <input type="hidden" name="idPersona" id="edit-idPersona">

                <div class="modal-header">
                    <h5 class="modal-title">Editar usuario</h5>
                    <button class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body row g-3">

                    <div class="col-md-6">
                        <label>Nombres</label>
                        <input type="text" name="nombres" id="edit-nombres" class="form-control" required
                               pattern="[A-Za-z ]+" title="Solo letras y espacios">
                    </div>

                    <div class="col-md-6">
                        <label>Apellidos</label>
                        <input type="text" name="apellidos" id="edit-apellidos" class="form-control" required
                               pattern="[A-Za-z ]+" title="Solo letras y espacios">
                    </div>

                    <div class="col-md-4">
                        <label>DNI</label>
                        <input type="text" name="dni" id="edit-dni" class="form-control"
                               maxlength="8" pattern="[0-9]{8}" title="8 digitos numericos">
                    </div>

                    <div class="col-md-4">
                        <label>Teléfono</label>
                        <input type="text" name="telefono" id="edit-telefono" class="form-control"
                               maxlength="9" pattern="[0-9]{9}" title="9 digitos numericos">
                    </div>

                    <div class="col-md-4">
                        <label>Correo</label>
                        <input type="email" name="correo" id="edit-correo" class="form-control">
                    </div>

                    <div class="col-md-12">
                        <label>Dirección</label>
                        <input type="text" name="direccion" id="edit-direccion" class="form-control">
                    </div>

                    <hr>

                    <div class="col-md-6">
                        <label>Usuario</label>
                        <input type="text" name="usuario" id="edit-usuario" class="form-control" required>
                    </div>

                    <div class="col-md-6">
                        <label>Contraseña (opcional)</label>
                        <input type="password" name="contrasena" class="form-control">
                    </div>

                    <div class="col-md-6">
                        <label>Rol</label>
                        <select name="rol" id="edit-rol" class="form-select">
                            <option>Administrador</option>
                            <option>Vendedor</option>
                        </select>
                    </div>

                    <div class="col-md-6">
                        <label>Estado</label>
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
/* ========= Rellenar Modal de Edición ========= */
document.querySelectorAll(".btn-editar").forEach(btn => {
    btn.addEventListener("click", () => {

        document.getElementById("edit-idUsuario").value = btn.dataset.idusuario;
        document.getElementById("edit-idPersona").value = btn.dataset.idpersona;

        document.getElementById("edit-nombres").value   = btn.dataset.nombres;
        document.getElementById("edit-apellidos").value = btn.dataset.apellidos;
        document.getElementById("edit-dni").value       = btn.dataset.dni;
        document.getElementById("edit-telefono").value  = btn.dataset.telefono;
        document.getElementById("edit-correo").value    = btn.dataset.correo;
        document.getElementById("edit-direccion").value = btn.dataset.direccion;
        document.getElementById("edit-usuario").value   = btn.dataset.usuario;

        document.getElementById("edit-rol").value       = btn.dataset.rol;
        document.getElementById("edit-estado").value    = btn.dataset.estado;

        new bootstrap.Modal(document.getElementById("modalEditar")).show();
    });
});

/* ========= VALIDACION FORMULARIOS ========= */
function validarUsuarioForm(form) {
    const nombres   = form.nombres.value.trim();
    const apellidos = form.apellidos.value.trim();
    const dni       = form.dni.value.trim();
    const telefono  = form.telefono.value.trim();

    if (!/^[A-Za-z ]+$/.test(nombres)) {
        alert("Los nombres solo deben contener letras y espacios");
        return false;
    }
    if (!/^[A-Za-z ]+$/.test(apellidos)) {
        alert("Los apellidos solo deben contener letras y espacios");
        return false;
    }
    if (!/^[0-9]{8}$/.test(dni)) {
        alert("El DNI debe tener 8 digitos y solo numeros");
        return false;
    }
    if (telefono && !/^[0-9]{9}$/.test(telefono)) {
        alert("El telefono debe tener 9 digitos y solo numeros");
        return false;
    }
    return true;
}

const formNuevoModal  = document.querySelector("#modalNuevo form");
const formEditarModal = document.querySelector("#modalEditar form");

if (formNuevoModal) {
    formNuevoModal.addEventListener("submit", e => {
        if (!validarUsuarioForm(formNuevoModal)) e.preventDefault();
    });
}
if (formEditarModal) {
    formEditarModal.addEventListener("submit", e => {
        if (!validarUsuarioForm(formEditarModal)) e.preventDefault();
    });
}

/* ========= TOAST ========= */
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
});

setTimeout(cerrarToast, 4000);
</script>

</body>
</html>



