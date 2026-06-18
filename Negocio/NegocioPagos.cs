using System;
using Dominio;

namespace Negocio
{
    public class NegocioPagos
    {
        // Registra un pago sobre una reserva. No toca el estado de pago de la
        // reserva: de eso se encarga el trigger TR_SincronizarEstadoPago, que
        // recalcula Señado/Pagado a partir de la suma de pagos al insertar acá.
        public void RegistrarPago(Pago pago, int idReserva)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetearConsulta(@"
                    INSERT INTO Pagos (Monto, IDReserva, IDFormaPago)
                    VALUES (@monto, @idReserva, @idFormaPago)");
                datos.AgregarParametro("@monto", pago.Monto);
                datos.AgregarParametro("@idReserva", idReserva);
                datos.AgregarParametro("@idFormaPago", (int)pago.FormaDePago);
                datos.EjecutarAccion();
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        // Cuánto se pagó hasta ahora de una reserva. Sirve para mostrar el saldo
        // pendiente en el modal antes de registrar un pago nuevo.
        public decimal ObtenerTotalPagado(int idReserva)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetearConsulta(@"
                    SELECT ISNULL(SUM(Monto), 0) AS Total
                    FROM Pagos
                    WHERE IDReserva = @idReserva");
                datos.AgregarParametro("@idReserva", idReserva);
                datos.EjecutarLectura();

                if (datos.Lector.Read())
                    return (decimal)datos.Lector["Total"];

                return 0m;
            }
            finally
            {
                datos.CerrarConexion();
            }
        }
    }
}
