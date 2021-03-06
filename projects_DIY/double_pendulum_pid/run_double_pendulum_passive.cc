///
/// @brief  An SDF based double pendulum example.
///
#include <memory>

#include <gflags/gflags.h>

#include "drake/common/drake_assert.h"
#include "drake/common/find_resource.h"
#include "drake/common/text_logging.h"
#include "drake/geometry/drake_visualizer.h"
#include "drake/geometry/scene_graph.h"
#include "drake/lcm/drake_lcm.h"
#include "drake/multibody/parsing/parser.h"
#include "drake/multibody/plant/multibody_plant.h"
#include "drake/systems/analysis/simulator.h"
#include "drake/systems/framework/diagram.h"
#include "drake/systems/framework/diagram_builder.h"
#include "drake/math/rigid_transform.h"

DEFINE_double(target_realtime_rate, 1.0,
              "Rate at which to run the simulation, relative to realtime");
DEFINE_double(simulation_time, 10, "How long to simulate the pendulum");
DEFINE_double(time_step, 1.0e-3,
              "Simulation time step used for integrator.");

namespace drake {
namespace projects_DIY {
//namespace multibody{
namespace double_pendulum_pid {
namespace {

using geometry::SceneGraph;
using geometry::SourceId;
using lcm::DrakeLcm;

using drake::multibody::MultibodyPlant;
using drake::multibody::Parser;

// Fixed path to double pendulum SDF model.
static const char* const SdfPath =
    "drake/projects_DIY/double_pendulum_pid/models/double_pendulum.sdf";
// note that drake is the name of the WORKSPACE not the name of the root file. The name is defined in the WORKSPACE file under the root file "drake_sim"

//
// Main function for demo.
//
int DoMain() {
  DRAKE_DEMAND(FLAGS_simulation_time > 0);

  systems::DiagramBuilder<double> builder;

  SceneGraph<double>& scene_graph = *builder.AddSystem<SceneGraph>();
  scene_graph.set_name("scene_graph");

  /*
  // Load and parse double pendulum SDF from file into a tree.
  multibody::MultibodyPlant<double>* dp =
      builder.AddSystem<multibody::MultibodyPlant<double>>(FLAGS_max_time_step);
  dp->set_name("plant");
  dp->RegisterAsSourceForSceneGraph(&scene_graph);

  multibody::Parser parser(dp);
  const std::string sdf_path = FindResourceOrThrow(kDoublePendulumSdfPath);
  multibody::ModelInstanceIndex plant_model_instance_index =
      parser.AddModelFromFile(sdf_path);
  (void)plant_model_instance_index;

  // Weld the base link to world frame with no rotation.
  const auto& root_link = dp->GetBodyByName("base");
  dp->AddJoint<multibody::WeldJoint>("weld_base", dp->world_body(), std::nullopt,
                                     root_link, std::nullopt,
                                     Isometry3<double>::Identity());
  // Now the plant is complete.
  dp->Finalize();
  */
  const std::string full_name= FindResourceOrThrow(SdfPath);
  MultibodyPlant<double>& dp = *builder.AddSystem<MultibodyPlant>(FLAGS_time_step);
  Parser(&dp, &scene_graph).AddModelFromFile(full_name);

  const auto& root_link = dp.GetBodyByName("base");
  dp.AddJoint<multibody::WeldJoint>("weld_base", dp.world_body(), std::nullopt,
                                     root_link, std::nullopt,
                                     math::RigidTransformd::Identity());
                                     //Isometry3<double>::Identity());

  dp.Finalize();
  
  // Connect plant with scene_graph to get collision information.
  DRAKE_DEMAND(!!dp.get_source_id());
  builder.Connect(
      dp.get_geometry_poses_output_port(),
      scene_graph.get_source_pose_port(dp.get_source_id().value()));
  builder.Connect(scene_graph.get_query_output_port(),
                  dp.get_geometry_query_input_port());

  //geometry::ConnectDrakeVisualizer(&builder, scene_graph);
  geometry::DrakeVisualizerd::AddToBuilder(&builder, scene_graph);

  auto diagram = builder.Build();
  std::unique_ptr<systems::Context<double>> diagram_context =
      diagram->CreateDefaultContext();
  diagram->SetDefaultContext(diagram_context.get());

  // Create plant_context to set velocity.
  systems::Context<double>& plant_context =
      diagram->GetMutableSubsystemContext(dp, diagram_context.get());

  // Set init position.
  Eigen::VectorXd positions = Eigen::VectorXd::Zero(dp.num_positions());
  positions[0] = 0.1;
  positions[1] = 0;
   // positions[2] = 0.4;
  dp.SetPositions(&plant_context, positions);

  systems::Simulator<double> simulator(*diagram, std::move(diagram_context));
  simulator.set_publish_every_time_step(false);
  simulator.set_target_realtime_rate(FLAGS_target_realtime_rate);
  simulator.Initialize();
  simulator.AdvanceTo(FLAGS_simulation_time);
  
  return 0;
}

}  // namespace
}  // namespace double_pendulum
//}  // namespace multibody
}  // namespace examples
}  // namespace drake

int main(int argc, char** argv) {
  gflags::SetUsageMessage(
      "bazel run "
      "//examples/double_pendulum_pid:run_double_pendulum_passive_exe");
  gflags::ParseCommandLineFlags(&argc, &argv, true);
  return  drake::projects_DIY::double_pendulum_pid::DoMain();
}
