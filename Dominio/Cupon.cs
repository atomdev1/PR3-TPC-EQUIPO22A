using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Dominio.Enums;

namespace Dominio
{
    public class Cupon
    {
        public int IdCupon { get; set; }
        public string Codigo { get; set; }
        public string Descripcion { get; set; }
        public EstadoCupon Estado { get; set; }
        public int IdUsuario { get; set; }
        public Usuario Usuario { get; set; }
        public TipoDescuento TipoDescuento { get; set; }
        public decimal? ValorDescuento { get; set; }
        public int ReservasRequeridas { get; set; }
        public DateTime? ValidoDesde { get; set;  }
        public DateTime? ValidoHasta { get; set; }
        public int? LimiteUsos { get; set; }
        public int UsosActuales { get; set; }

    }
}
