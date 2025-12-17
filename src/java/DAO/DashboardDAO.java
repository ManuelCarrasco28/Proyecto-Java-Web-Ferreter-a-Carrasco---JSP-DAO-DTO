package DAO;

import UTIL.Conexion;
import java.sql.*;
import java.util.*;

public class DashboardDAO {

    // 1. Ventas del día → idOperacion = 2
    public double ventasDelDia() {
        double total = 0;

        String sql =
            "SELECT SUM(total) AS monto " +
            "FROM Transacciones " +
            "WHERE idOperacion = 2 " +
            "AND DATE(fechaTransaccion) = CURDATE()";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) total = rs.getDouble("monto");

        } catch (Exception e) {
            System.out.println("Error ventasDelDia: " + e.getMessage());
        }
        return total;
    }


    // 2. Productos con stock bajo
    public int productosStockBajo() {
        int cant = 0;

        String sql =
            "SELECT COUNT(*) AS total " +
            "FROM Productos " +
            "WHERE stock <= 5";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) cant = rs.getInt("total");

        } catch (Exception e) {
            System.out.println("Error productosStockBajo: " + e.getMessage());
        }
        return cant;
    }

    // 2b. Listar productos con stock bajo (para detalle)
    public List<String[]> listarStockBajo(int limite) {
        List<String[]> lista = new ArrayList<>();
        String sql = "SELECT nombreProducto, stock FROM Productos WHERE stock <= 5 ORDER BY stock ASC LIMIT ?";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, limite);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                lista.add(new String[]{rs.getString("nombreProducto"), String.valueOf(rs.getInt("stock"))});
            }

        } catch (Exception e) {
            System.out.println("Error listarStockBajo: " + e.getMessage());
        }
        return lista;
    }


    // 3. Clientes nuevos del mes (idTipoPersona = 2)
    public int clientesNuevos() {
        int cant = 0;

        String sql =
            "SELECT COUNT(*) AS total " +
            "FROM Persona " +
            "WHERE idTipoPersona = 2 " +
            "AND MONTH(fechaRegistro) = MONTH(CURDATE()) " +
            "AND YEAR(fechaRegistro) = YEAR(CURDATE())";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) cant = rs.getInt("total");

        } catch (Exception e) {
            System.out.println("Error clientesNuevos: " + e.getMessage());
        }
        return cant;
    }


    // 4. Ventas mensuales
    public List<Double> ventasMensuales() {
        List<Double> lista = new ArrayList<>();
        double[] meses = new double[12];

        String sql =
            "SELECT MONTH(fechaTransaccion) AS mes, SUM(total) AS monto " +
            "FROM Transacciones " +
            "WHERE idOperacion = 2 " +
            "AND YEAR(fechaTransaccion) = YEAR(CURDATE()) " +
            "GROUP BY MONTH(fechaTransaccion)";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                meses[rs.getInt("mes") - 1] = rs.getDouble("monto");
            }

        } catch (Exception e) {
            System.out.println("Error ventasMensuales: " + e.getMessage());
        }

        for (double m : meses) lista.add(m);
        return lista;
    }


    // 5. Compras mensuales
    public List<Double> comprasMensuales() {
        List<Double> lista = new ArrayList<>();
        double[] meses = new double[12];

        String sql =
            "SELECT MONTH(fechaTransaccion) AS mes, SUM(total) AS monto " +
            "FROM Transacciones " +
            "WHERE idOperacion = 1 " +
            "AND YEAR(fechaTransaccion) = YEAR(CURDATE()) " +
            "GROUP BY MONTH(fechaTransaccion)";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                meses[rs.getInt("mes") - 1] = rs.getDouble("monto");
            }

        } catch (Exception e) {
            System.out.println("Error comprasMensuales: " + e.getMessage());
        }

        for (double m : meses) lista.add(m);
        return lista;
    }

    // 6. Top productos más vendidos (idOperacion = 2)
    public List<String[]> productosMasVendidos(int limite) {
        List<String[]> lista = new ArrayList<>();

        String sql = "SELECT p.nombreProducto AS nombre, SUM(d.cantidad) AS total "
                   + "FROM detalletransacciones d "
                   + "INNER JOIN transacciones t ON d.idTransaccion = t.idTransaccion "
                   + "INNER JOIN productos p ON d.idProducto = p.idProducto "
                   + "WHERE t.idOperacion = 2 "
                   + "GROUP BY p.idProducto "
                   + "ORDER BY total DESC "
                   + "LIMIT ?";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, limite);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                lista.add(new String[]{rs.getString("nombre"), String.valueOf(rs.getInt("total"))});
            }

        } catch (Exception e) {
            System.out.println("Error productosMasVendidos: " + e.getMessage());
        }

        return lista;
    }

}
