package DAO;

import DTO.CompraDTO;
import DTO.DetalleCompraDTO;
import UTIL.Conexion;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CompraDAO {

    /* ============================================================
          REGISTRAR COMPRA (CON AUMENTO DE STOCK)
       ============================================================ */
    public boolean registrarCompra(int idProveedor,
                                   int idUsuario,
                                   String metodoPago,
                                   double total,
                                   List<DetalleCompraDTO> carrito) {

        String sqlTransaccion =
                "INSERT INTO transacciones (idOperacion, idPersona, idUsuario, metodoPago, total) "
                        + "VALUES (1, ?, ?, ?, ?)";

        String sqlDetalle =
                "INSERT INTO detalletransacciones (idTransaccion, idProducto, cantidad, precioUnitario) "
                        + "VALUES (?, ?, ?, ?)";

        try (Connection cn = Conexion.conectar()) {

            cn.setAutoCommit(false);

            // 1. Registrar compra
            PreparedStatement ps = cn.prepareStatement(sqlTransaccion, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, idProveedor);
            ps.setInt(2, idUsuario);
            ps.setString(3, metodoPago);
            ps.setDouble(4, total);
            ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();
            rs.next();
            int idTransaccion = rs.getInt(1);

            // 2. Registrar detalle
            PreparedStatement psDet = cn.prepareStatement(sqlDetalle);

            ProductoDAO pdao = new ProductoDAO(); // Para actualizar stock

            for (DetalleCompraDTO d : carrito) {

                // Insertar detalle
                psDet.setInt(1, idTransaccion);
                psDet.setInt(2, d.getIdProducto());
                psDet.setInt(3, d.getCantidad());
                psDet.setDouble(4, d.getPrecioUnitario());
                psDet.addBatch();

                // Aumentar stock
                pdao.aumentarStock(d.getIdProducto(), d.getCantidad());
            }

            psDet.executeBatch();
            cn.commit();
            return true;

        } catch (Exception e) {
            System.out.println("Error registrarCompra: " + e.getMessage());
            return false;
        }
    }



    /* ============================================================
          LISTAR COMPRAS POR FECHA
       ============================================================ */
    public List<CompraDTO> listarComprasPorFecha(String f1, String f2) {
        List<CompraDTO> lista = new ArrayList<>();

        String sql =
                "SELECT t.idTransaccion, p.razonSocial AS proveedor, "
              + "u.usuario AS usuario, t.metodoPago, t.fechaTransaccion, t.total "
              + "FROM transacciones t "
              + "INNER JOIN persona p ON t.idPersona = p.idPersona "
              + "INNER JOIN usuarios u ON t.idUsuario = u.idUsuario "
              + "WHERE t.idOperacion = 1 AND DATE(t.fechaTransaccion) BETWEEN ? AND ? "
              + "ORDER BY t.fechaTransaccion DESC";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, f1);
            ps.setString(2, f2);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                CompraDTO c = new CompraDTO();

                c.setIdTransaccion(rs.getInt("idTransaccion"));
                c.setProveedor(rs.getString("proveedor"));
                c.setUsuario(rs.getString("usuario"));
                c.setMetodoPago(rs.getString("metodoPago"));
                c.setFecha(rs.getString("fechaTransaccion"));
                c.setTotal(rs.getDouble("total"));

                lista.add(c);
            }

        } catch (Exception e) {
            System.out.println("Error listarComprasPorFecha: " + e.getMessage());
        }

        return lista;
    }



    /* ============================================================
          LISTAR TODAS LAS COMPRAS
       ============================================================ */
    public List<CompraDTO> listarCompras() {
        List<CompraDTO> lista = new ArrayList<>();

        String sql =
                "SELECT t.idTransaccion, p.razonSocial AS proveedor, "
              + "u.usuario AS usuario, t.metodoPago, t.fechaTransaccion, t.total "
              + "FROM transacciones t "
              + "INNER JOIN persona p ON t.idPersona = p.idPersona "
              + "INNER JOIN usuarios u ON t.idUsuario = u.idUsuario "
              + "WHERE t.idOperacion = 1 "
              + "ORDER BY t.fechaTransaccion DESC";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                CompraDTO c = new CompraDTO();

                c.setIdTransaccion(rs.getInt("idTransaccion"));
                c.setProveedor(rs.getString("proveedor"));
                c.setUsuario(rs.getString("usuario"));
                c.setMetodoPago(rs.getString("metodoPago"));
                c.setFecha(rs.getString("fechaTransaccion"));
                c.setTotal(rs.getDouble("total"));

                lista.add(c);
            }

        } catch (Exception e) {
            System.out.println("Error listarCompras: " + e.getMessage());
        }

        return lista;
    }
}
