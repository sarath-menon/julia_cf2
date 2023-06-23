
@pydef mutable struct Cf2Logger
    function __init__(self, uri="usb://0")

        self.uri = uri

        # package imports
        self.cflib = pyimport("cflib")
        self.time = pyimport("time")

        self.crazyflie = pyimport("cflib.crazyflie")
        self.log = pyimport("cflib.crazyflie.log")
        self.syncLogger = pyimport("cflib.crazyflie.syncLogger")

        # Only output errors from the logging framework
        logging = pyimport("logging")
        logging.basicConfig(level=logging.ERROR)

        # Initialize the low-level drivers
        self.cflib.crtp.init_drivers()

        self.lg_stab = log.LogConfig(name="Stabilizer", period_in_ms=10)
        self.lg_stab.add_variable("gyro_unfiltered.x", "float")
        self.lg_stab.add_variable("gyro_unfiltered.y", "float")
        self.lg_stab.add_variable("gyro_unfiltered.z", "float")


        # test
        self.x = 4
    end

    # setter function 
    function simple_log(self, scf)
        @pywith self.crazyflie.syncLogger.SyncLogger(scf, self.lg_stab) as logger begin

            count = 0
            println("selva")

            for log_entry in logger

                timestamp = log_entry[1]
                data = log_entry[2]
                logconf_name = log_entry[3]

                # print('[%d][%s]: %s' % (timestamp, logconf_name, data))
                print("Timestamp: ", timestamp)

                @printf "   Raw gyro: %.3f    %.3f    %.3f" data["gyro_unfiltered.x"] data["gyro_unfiltered.y"] data["gyro_unfiltered.z"]

                println("")

                # push data to circular buffer
                sample = [data["gyro_unfiltered.x"] data["gyro_unfiltered.y"] data["gyro_unfiltered.z"]]
                # push!(cb, sample)

                # push data to plot buffer
                if count % 10 == 0
                    points[] = push!(points[], [(count / 1000) data["gyro_unfiltered.x"]])
                end

                count += 1

                if count == 10000
                    break
                end
            end
        end

    end

    function log_start(self)
        @async begin
            @pywith self.crazyflie.syncCrazyflie.SyncCrazyflie(self.uri, cf=self.crazyflie.Crazyflie(rw_cache="./cache")) as scf begin
                # print("Hello World!")
                self.simple_log(scf)
            end
        end
    end

    # getter function 
    x2.get(self) = self.x * 2

    function x2.set!(self, new_val)
        self.x = new_val / 2
    end
end

