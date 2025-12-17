package DAO;

import DTO.VentaDTO;
import DTO.DetalleVentaDTO;
import UTIL.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class VentaDAO {

    /* ============================================================
          REGISTRAR VENTA  (CON ROLLBACK Y CONTROL DE STOCK)
       ============================================================ */
    public boolean registrarVenta(int idCliente,
                                  int idUsuario,
                                  String metodoPago,
                                  double total,
                                  List<DetalleVentaDTO> carrito) {

        String sqlTransaccion =
                "INSERT INTO transacciones (idOperacion, idPersona, idUsuario, metodoPago, total) "
                        + "VALUES (2, ?, ?, ?, ?)";

        String sqlDetalle =
                "INSERT INTO detalletransacciones (idTransaccion, idProducto, cantidad, precioUnitario) "
                        + "VALUES (?, ?, ?, ?)";

        String sqlStock =
                "UPDATE productos SET stock = stock - ? WHERE idProducto = ? AND stock >= ?";

        try (Connection cn = Conexion.conectar()) {

            cn.setAutoCommit(false);

            // Registrar venta
            PreparedStatement ps = cn.prepareStatement(sqlTransaccion, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, idCliente);
            ps.setInt(2, idUsuario);
            ps.setString(3, metodoPago);
            ps.setDouble(4, total);
            ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();
            rs.next();
            int idTransaccion = rs.getInt(1);

            // Registrar detalle y actualizar stock
            PreparedStatement psDetalle = cn.prepareStatement(sqlDetalle);
            PreparedStatement psStock = cn.prepareStatement(sqlStock);

            for (DetalleVentaDTO d : carrito) {

                // 🟢 Verificar stock suficiente
                psStock.setInt(1, d.getCantidad());
                psStock.setInt(2, d.getIdProducto());
                psStock.setInt(3, d.getCantidad());

                int filasStock = psStock.executeUpdate();
                if (filasStock == 0) {
                    cn.rollback();
                    System.out.println("Error registrarVenta: Stock insuficiente");
                    return false;
                }

                // Detalle
                psDetalle.setInt(1, idTransaccion);
                psDetalle.setInt(2, d.getIdProducto());
                psDetalle.setInt(3, d.getCantidad());
                psDetalle.setDouble(4, d.getPrecioUnitario());
                psDetalle.addBatch();
            }

            psDetalle.executeBatch();
            cn.commit();

            return true;

        } catch (Exception e) {
            System.out.println("Error registrarVenta: " + e.getMessage());
            return false;
        }
    }



    /* ============================================================
          LISTAR VENTAS POR FECHA
       ============================================================ */
    public List<VentaDTO> listarVentasPorFecha(String f1, String f2) {
        List<VentaDTO> lista = new ArrayList<>();

        String sql = "SELECT t.idTransaccion, " +
                "CONCAT(p.nombres,' ',p.apellidos) AS cliente, " +
                "u.usuario AS usuario, " +
                "t.metodoPago, t.fechaTransaccion, t.total " +
                "FROM transacciones t " +
                "INNER JOIN persona p ON t.idPersona = p.idPersona " +
                "INNER JOIN usuarios u ON t.idUsuario = u.idUsuario " +
                "WHERE t.idOperacion = 2 AND DATE(t.fechaTransaccion) BETWEEN ? AND ? " +
                "ORDER BY t.fechaTransaccion DESC";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, f1);
            ps.setString(2, f2);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                VentaDTO v = new VentaDTO();
                v.setIdTransaccion(rs.getInt("idTransaccion"));
                v.setCliente(rs.getString("cliente"));
                v.setUsuario(rs.getString("usuario"));
                v.setMetodoPago(rs.getString("metodoPago"));
                v.setFecha(rs.getString("fechaTransaccion"));
                v.setTotal(rs.getDouble("total"));
                lista.add(v);
            }

        } catch (Exception e) {
            System.out.println("Error listarVentasPorFecha: " + e.getMessage());
        }

        return lista;
    }



    /* ============================================================
          LISTAR TODAS LAS VENTAS
       ============================================================ */
    public List<VentaDTO> listarVentas() {
        List<VentaDTO> lista = new ArrayList<>();

        String sql = "SELECT t.idTransaccion, " +
                "CONCAT(p.nombres,' ',p.apellidos) AS cliente, " +
                "u.usuario AS usuario, " +
                "t.metodoPago, t.fechaTransaccion, t.total " +
                "FROM transacciones t " +
                "INNER JOIN persona p ON t.idPersona = p.idPersona " +
                "INNER JOIN usuarios u ON t.idUsuario = u.idUsuario " +
                "WHERE t.idOperacion = 2 " +
                "ORDER BY t.fechaTransaccion DESC";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                VentaDTO v = new VentaDTO();
                v.setIdTransaccion(rs.getInt("idTransaccion"));
                v.setCliente(rs.getString("cliente"));
                v.setUsuario(rs.getString("usuario"));
                v.setMetodoPago(rs.getString("metodoPago"));
                v.setFecha(rs.getString("fechaTransaccion"));
                v.setTotal(rs.getDouble("total"));
                lista.add(v);
            }

        } catch (Exception e) {
            System.out.println("Error listarVentas: " + e.getMessage());
        }

        return lista;
    }
}
