using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using Dominio;

namespace WebApp
{
    public partial class Canchas : System.Web.UI.Page
    {
        protected Repeater rptCanchas;
        protected Label lblTotal;
        protected Button btnNuevaCancha;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CargarCanchas();
            }
        }

        private void CargarCanchas()
        {
            List<Cancha> canchas = new List<Cancha>
            {
                new Cancha { IdCancha = 1, NombreFantasia = "Cancha Tenis Central", Precio = 6000, IdDeporte = 1, Deporte = new Deporte { IdDeporte = 1, Nombre = "Tenis", DuracionMinutos = 60 }, CapacidadJugadores = 4, Descripcion = "Polvo de ladrillo · Iluminación", Activa = true },
                new Cancha { IdCancha = 2, NombreFantasia = "Cancha Vóley Playa", Precio = 5000, IdDeporte = 4, Deporte = new Deporte { IdDeporte = 4, Nombre = "Voley", DuracionMinutos = 60 }, CapacidadJugadores = 12, Descripcion = "Arena", Activa = true },
                new Cancha { IdCancha = 3, NombreFantasia = "Cancha Pádel 1", Precio = 8000, IdDeporte = 2, Deporte = new Deporte { IdDeporte = 2, Nombre = "Pádel", DuracionMinutos = 60 }, CapacidadJugadores = 4, Descripcion = "Césped sintético · Techada", Activa = true },
                new Cancha { IdCancha = 4, NombreFantasia = "Cancha Fútbol 5 - A", Precio = 15000, IdDeporte = 3, Deporte = new Deporte { IdDeporte = 3, Nombre = "Fútbol", DuracionMinutos = 90 }, CapacidadJugadores = 10, Descripcion = "Césped sintético · Iluminación", Activa = true },
                new Cancha { IdCancha = 5, NombreFantasia = "Cancha Fútbol 5 - B", Precio = 15000, IdDeporte = 3, Deporte = new Deporte { IdDeporte = 3, Nombre = "Fútbol", DuracionMinutos = 90 }, CapacidadJugadores = 10, Descripcion = "Césped sintético", Activa = false },
                new Cancha { IdCancha = 6, NombreFantasia = "Cancha Básquet", Precio = 10000, IdDeporte = 5, Deporte = new Deporte { IdDeporte = 5, Nombre = "Básquet", DuracionMinutos = 40 }, CapacidadJugadores = 10, Descripcion = "Cemento · Techada · Iluminación", Activa = true },
            };

            rptCanchas.DataSource = canchas;
            rptCanchas.DataBind();

            lblTotal.Text = canchas.Count + " canchas registradas";
        }

        protected void rptCanchas_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int idCancha = int.Parse(e.CommandArgument.ToString());

            if (e.CommandName == "Editar")
            {
                Response.Redirect("EditarCancha.aspx?id=" + idCancha);
            }
            else if (e.CommandName == "Eliminar")
            {
                // HACER: llamar a la capa Negocio para "eliminar" (baja logica)
            }
        }

        protected void btnNuevaCancha_Click(object sender, EventArgs e)
        {
            Response.Redirect("NuevaCancha.aspx");
        }
    }
}
