using System;
using Dominio.Enums;

namespace Dominio
{
    // El "molde" de un beneficio de fidelidad: la regla fija del complejo.
    // NO es un cupón emitido — no tiene dueño, código, estado ni usos.
    // El cupón se genera (vía trigger) recién cuando el cliente alcanza el umbral.
    public class BeneficioFidelidad
    {
        public int IdBeneficio { get; set; }
        public string Nombre { get; set; }
        public string Descripcion { get; set; }
        public int ReservasRequeridas { get; set; }
        public TipoDescuento TipoDescuento { get; set; }
        public decimal? ValorDescuento { get; set; }
        public int? DiasValidez { get; set; }
        public bool Activo { get; set; }

        // Comportamiento: el objeto sabe responder sobre el progreso del cliente.
        // En vez de que la vista calcule, le preguntamos al beneficio.

        public int ReservasFaltantes(int reservasDelCliente)
        {
            int faltan = ReservasRequeridas - reservasDelCliente;
            return faltan > 0 ? faltan : 0;
        }

        public bool YaAlcanzado(int reservasDelCliente)
        {
            return reservasDelCliente >= ReservasRequeridas;
        }

        public int PorcentajeProgreso(int reservasDelCliente)
        {
            if (ReservasRequeridas <= 0) return 100;
            int progreso = reservasDelCliente * 100 / ReservasRequeridas;
            return progreso > 100 ? 100 : progreso;
        }
    }
}
